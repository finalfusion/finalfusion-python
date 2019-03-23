#![feature(specialization)]

use std::cell::RefCell;
use std::fs::File;
use std::io::{BufReader, BufWriter};
use std::rc::Rc;

use failure::Error;
use finalfusion::metadata::Metadata;
use finalfusion::prelude::*;
use finalfusion::similarity::*;
use pyo3::class::{basic::PyObjectProtocol, iter::PyIterProtocol};
use pyo3::exceptions;
use pyo3::prelude::*;
use toml::{self, Value};

/// This is a Python module for using finalfusion embeddings.
///
/// finalfusion is a format for word embeddings that supports words,
/// subwords, memory-mapped matrices, and quantized matrices.
#[pymodinit]
fn finalfusion(_py: Python, m: &PyModule) -> PyResult<()> {
    m.add_class::<PyEmbeddings>()?;
    m.add_class::<PyWordSimilarity>()?;
    Ok(())
}

/// A word and its similarity to a query word.
///
/// The similarity is normally a value between -1 (opposite
/// vectors) and 1 (identical vectors).
#[pyclass(name=WordSimilarity)]
struct PyWordSimilarity {
    #[prop(get)]
    word: String,

    #[prop(get)]
    similarity: f32,

    token: PyToken,
}

#[pyproto]
impl PyObjectProtocol for PyWordSimilarity {
    fn __repr__(&self) -> PyResult<String> {
        Ok(format!(
            "WordSimilarity('{}', {})",
            self.word, self.similarity
        ))
    }

    fn __str__(&self) -> PyResult<String> {
        Ok(format!("{}: {}", self.word, self.similarity))
    }
}

enum EmbeddingsWrap {
    NonView(Embeddings<VocabWrap, StorageWrap>),
    View(Embeddings<VocabWrap, StorageViewWrap>),
}

/// finalfusion embeddings.
#[pyclass(name=Embeddings)]
struct PyEmbeddings {
    // The use of Rc + RefCell should be safe in this crate:
    //
    // 1. Python is single-threaded.
    // 2. The only mutable borrow (in set_metadata) is limited
    //    to its method scope.
    // 3. None of the methods returns borrowed embeddings.
    embeddings: Rc<RefCell<EmbeddingsWrap>>,
    token: PyToken,
}

#[pymethods]
impl PyEmbeddings {
    /// Load embeddings from the given `path`.
    ///
    /// When the `mmap` argument is `True`, the embedding matrix is
    /// not loaded into memory, but memory mapped. This results in
    /// lower memory use and shorter load times, while sacrificing
    /// some query efficiency.
    #[new]
    #[args(mmap = false)]
    fn __new__(obj: &PyRawObject, path: &str, mmap: bool) -> PyResult<()> {
        // First try to load embeddings with viewable storage. If that
        // fails, attempt to load the embeddings as non-viewable
        // storage.
        let embeddings = match load_embeddings(path, mmap) {
            Ok(e) => Rc::new(RefCell::new(EmbeddingsWrap::View(e))),
            Err(_) => load_embeddings(path, mmap)
                .map(|e| Rc::new(RefCell::new(EmbeddingsWrap::NonView(e))))
                .map_err(|err| exceptions::IOError::py_err(err.to_string()))?,
        };

        obj.init(|token| PyEmbeddings { embeddings, token })
    }

    /// Perform an anology query.
    ///
    /// This returns words for the analogy query *w1* is to *w2*
    /// as *w3* is to ?.
    #[args(limit = 10)]
    fn analogy(
        &self,
        py: Python,
        word1: &str,
        word2: &str,
        word3: &str,
        limit: usize,
    ) -> PyResult<Vec<PyObject>> {
        use EmbeddingsWrap::*;
        let embeddings = self.embeddings.borrow();
        let embeddings = match &*embeddings {
            View(e) => e,
            NonView(_) => {
                return Err(exceptions::ValueError::py_err(
                    "Analogy queries are not supported for this type of embedding matrix",
                ));
            }
        };

        let results = match embeddings.analogy(word1, word2, word3, limit) {
            Some(results) => results,
            None => return Err(exceptions::KeyError::py_err("Unknown word or n-grams")),
        };

        let mut r = Vec::with_capacity(results.len());
        for ws in results {
            r.push(
                Py::new(py, |token| PyWordSimilarity {
                    word: ws.word.to_owned(),
                    similarity: ws.similarity.into_inner(),
                    token,
                })?
                .into_object(py),
            )
        }

        Ok(r)
    }

    /// Get the embedding for the given word.
    ///
    /// If the word is not known, its representation is approximated
    /// using subword units.
    fn embedding(&self, word: &str) -> PyResult<Vec<f32>> {
        let embeddings = self.embeddings.borrow();

        use EmbeddingsWrap::*;
        let embedding = match &*embeddings {
            View(e) => e.embedding(word),
            NonView(e) => e.embedding(word),
        };

        match embedding {
            Some(embedding) => Ok(embedding.as_view().to_vec()),
            None => Err(exceptions::KeyError::py_err("Unknown word and n-grams")),
        }
    }

    /// Embeddings metadata.
    #[getter]
    fn metadata(&self) -> PyResult<Option<String>> {
        let embeddings = self.embeddings.borrow();

        use EmbeddingsWrap::*;
        let metadata = match &*embeddings {
            View(e) => e.metadata(),
            NonView(e) => e.metadata(),
        };

        match metadata.map(|v| toml::ser::to_string_pretty(&v.0)) {
            Some(Ok(toml)) => Ok(Some(toml)),
            Some(Err(err)) => Err(exceptions::IOError::py_err(format!(
                "Metadata is invalid TOML: {}",
                err
            ))),
            None => Ok(None),
        }
    }

    #[setter]
    fn set_metadata(&mut self, metadata: &str) -> PyResult<()> {
        let value = match metadata.parse::<Value>() {
            Ok(value) => value,
            Err(err) => {
                return Err(exceptions::ValueError::py_err(format!(
                    "Metadata is invalid TOML: {}",
                    err
                )));
            }
        };

        let mut embeddings = self.embeddings.borrow_mut();

        use EmbeddingsWrap::*;
        match &mut *embeddings {
            View(e) => e.set_metadata(Some(Metadata(value))),
            NonView(e) => e.set_metadata(Some(Metadata(value))),
        };

        Ok(())
    }

    /// Perform a similarity query.
    #[args(limit = 10)]
    fn similarity(&self, py: Python, word: &str, limit: usize) -> PyResult<Vec<PyObject>> {
        let embeddings = self.embeddings.borrow();

        use EmbeddingsWrap::*;
        let embeddings = match &*embeddings {
            View(e) => e,
            NonView(_) => {
                return Err(exceptions::ValueError::py_err(
                    "Similarity queries are not supported for this type of embedding matrix",
                ));
            }
        };

        let results = match embeddings.similarity(word, limit) {
            Some(results) => results,
            None => return Err(exceptions::KeyError::py_err("Unknown word and n-grams")),
        };

        let mut r = Vec::with_capacity(results.len());
        for ws in results {
            r.push(
                Py::new(py, |token| PyWordSimilarity {
                    word: ws.word.to_owned(),
                    similarity: ws.similarity.into_inner(),
                    token,
                })?
                .into_object(py),
            )
        }

        Ok(r)
    }

    /// Write the embeddings to a finalfusion file.
    fn write(&self, filename: &str) -> PyResult<()> {
        let f = File::create(filename)?;
        let mut writer = BufWriter::new(f);

        let embeddings = self.embeddings.borrow();

        use EmbeddingsWrap::*;
        match &*embeddings {
            View(e) => e
                .write_embeddings(&mut writer)
                .map_err(|err| exceptions::IOError::py_err(err.to_string())),
            NonView(e) => e
                .write_embeddings(&mut writer)
                .map_err(|err| exceptions::IOError::py_err(err.to_string())),
        }
    }
}

#[pyproto]
impl PyIterProtocol for PyEmbeddings {
    fn __iter__(&mut self) -> PyResult<PyObject> {
        let gil = Python::acquire_gil();
        let py = gil.python();
        let iter = Py::new(py, |token| PyEmbeddingIterator {
            embeddings: self.embeddings.clone(),
            idx: 0,
            token,
        })?
        .into_object(py);

        Ok(iter)
    }
}

fn load_embeddings<S>(path: &str, mmap: bool) -> Result<Embeddings<VocabWrap, S>, Error>
where
    Embeddings<VocabWrap, S>: ReadEmbeddings + MmapEmbeddings,
{
    let f = File::open(path)?;
    let mut reader = BufReader::new(f);

    let embeddings = if mmap {
        Embeddings::mmap_embeddings(&mut reader)?
    } else {
        Embeddings::read_embeddings(&mut reader)?
    };

    Ok(embeddings)
}

#[pyclass(name=EmbeddingIterator)]
struct PyEmbeddingIterator {
    embeddings: Rc<RefCell<EmbeddingsWrap>>,
    idx: usize,
    token: PyToken,
}

#[pyproto]
impl PyIterProtocol for PyEmbeddingIterator {
    fn __iter__(&mut self) -> PyResult<PyObject> {
        Ok(self.into())
    }

    fn __next__(&mut self) -> PyResult<Option<(String, Vec<f32>)>> {
        let embeddings = self.embeddings.borrow();

        use EmbeddingsWrap::*;
        let vocab = match &*embeddings {
            View(e) => e.vocab(),
            NonView(e) => e.vocab(),
        };

        if self.idx < vocab.len() {
            let word = vocab.words()[self.idx].to_string();

            let embed = match &*embeddings {
                View(e) => e.storage().embedding(self.idx),
                NonView(e) => e.storage().embedding(self.idx),
            };

            self.idx += 1;

            Ok(Some((word, embed.as_view().to_vec())))
        } else {
            Ok(None)
        }
    }
}
