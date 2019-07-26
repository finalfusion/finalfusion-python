use std::cell::RefCell;
use std::fs::File;
use std::io::{BufReader, BufWriter};
use std::rc::Rc;

use failure::Error;
use finalfusion::metadata::Metadata;
use finalfusion::prelude::*;
use finalfusion::similarity::*;
use itertools::Itertools;
use ndarray::Array2;
use numpy::{IntoPyArray, PyArray1, PyArray2};
use pyo3::class::iter::PyIterProtocol;
use pyo3::prelude::*;
use pyo3::types::PyTuple;
use pyo3::{exceptions, PyMappingProtocol};
use toml::{self, Value};

use crate::{EmbeddingsWrap, PyEmbeddingIterator, PyVocab, PyWordSimilarity};

/// finalfusion embeddings.
#[pyclass(name=Embeddings)]
pub struct PyEmbeddings {
    // The use of Rc + RefCell should be safe in this crate:
    //
    // 1. Python is single-threaded.
    // 2. The only mutable borrow (in set_metadata) is limited
    //    to its method scope.
    // 3. None of the methods returns borrowed embeddings.
    embeddings: Rc<RefCell<EmbeddingsWrap>>,
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

        obj.init(PyEmbeddings { embeddings });

        Ok(())
    }

    /// Get the model's vocabulary.
    fn vocab(&self) -> PyResult<PyVocab> {
        Ok(PyVocab::new(self.embeddings.clone()))
    }

    /// Perform an anology query.
    ///
    /// This returns words for the analogy query *w1* is to *w2*
    /// as *w3* is to ?.
    #[args(limit = 10, mask = "(true, true, true)")]
    fn analogy(
        &self,
        py: Python,
        word1: &str,
        word2: &str,
        word3: &str,
        limit: usize,
        mask: (bool, bool, bool),
    ) -> PyResult<Vec<PyObject>> {
        let embeddings = self.embeddings.borrow();

        let embeddings = embeddings.view().ok_or_else(|| {
            exceptions::ValueError::py_err(
                "Analogy queries are not supported for this type of embedding matrix",
            )
        })?;

        let results = embeddings
            .analogy_masked([word1, word2, word3], [mask.0, mask.1, mask.2], limit)
            .map_err(|lookup| {
                let failed = [word1, word2, word3]
                    .iter()
                    .zip(lookup.iter())
                    .filter(|(_, success)| !*success)
                    .map(|(word, _)| word)
                    .join(" ");
                exceptions::KeyError::py_err(format!("Unknown word or n-grams: {}", failed))
            })?;

        let mut r = Vec::with_capacity(results.len());
        for ws in results {
            r.push(
                Py::new(
                    py,
                    PyWordSimilarity::new(ws.word.to_owned(), ws.similarity.into_inner()),
                )?
                .into_object(py),
            )
        }

        Ok(r)
    }

    /// Get the embedding for the given word.
    ///
    /// If the word is not known, its representation is approximated
    /// using subword units.
    fn embedding(&self, word: &str) -> Option<Py<PyArray1<f32>>> {
        let embeddings = self.embeddings.borrow();

        embeddings.embedding(word).map(|e| {
            let gil = pyo3::Python::acquire_gil();
            e.into_owned().into_pyarray(gil.python()).to_owned()
        })
    }

    fn embedding_with_norm(&self, word: &str) -> Option<Py<PyTuple>> {
        let embeddings = self.embeddings.borrow();

        use EmbeddingsWrap::*;
        let embedding_with_norm = match &*embeddings {
            View(e) => e.embedding_with_norm(word),
            NonView(e) => e.embedding_with_norm(word),
        };

        embedding_with_norm.map(|e| {
            let gil = pyo3::Python::acquire_gil();
            let embedding = e.embedding.into_owned().into_pyarray(gil.python());
            (embedding, e.norm).into_py(gil.python())
        })
    }

    /// Copy the entire embeddings matrix.
    fn matrix_copy(&self) -> Py<PyArray2<f32>> {
        let embeddings = self.embeddings.borrow();

        use EmbeddingsWrap::*;
        let matrix = match &*embeddings {
            View(e) => e.storage().view().to_owned(),
            NonView(e) => match e.storage() {
                StorageWrap::MmapArray(mmap) => mmap.view().to_owned(),
                StorageWrap::NdArray(array) => array.0.to_owned(),
                StorageWrap::QuantizedArray(quantized) => {
                    let (rows, dims) = quantized.shape();
                    let mut array = Array2::<f32>::zeros((rows, dims));
                    for idx in 0..rows {
                        array
                            .row_mut(idx)
                            .assign(&quantized.embedding(idx).as_view());
                    }
                    array
                }
            },
        };
        let gil = pyo3::Python::acquire_gil();
        matrix.into_pyarray(gil.python()).to_owned()
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

        let embeddings = embeddings.view().ok_or_else(|| {
            exceptions::ValueError::py_err(
                "Similarity queries are not supported for this type of embedding matrix",
            )
        })?;

        let results = embeddings
            .word_similarity(word, limit)
            .ok_or_else(|| exceptions::KeyError::py_err("Unknown word and n-grams"))?;

        let mut r = Vec::with_capacity(results.len());
        for ws in results {
            r.push(
                Py::new(
                    py,
                    PyWordSimilarity::new(ws.word.to_owned(), ws.similarity.into_inner()),
                )?
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
impl PyMappingProtocol for PyEmbeddings {
    fn __getitem__(&self, word: &str) -> PyResult<Py<PyArray1<f32>>> {
        let embeddings = self.embeddings.borrow();

        match embeddings.embedding(word) {
            Some(embedding) => {
                let gil = pyo3::Python::acquire_gil();
                Ok(embedding.into_owned().into_pyarray(gil.python()).to_owned())
            }
            None => Err(exceptions::KeyError::py_err("Unknown word and n-grams")),
        }
    }
}

#[pyproto]
impl PyIterProtocol for PyEmbeddings {
    fn __iter__(slf: PyRefMut<Self>) -> PyResult<PyObject> {
        let gil = Python::acquire_gil();
        let py = gil.python();
        let iter =
            Py::new(py, PyEmbeddingIterator::new(slf.embeddings.clone(), 0))?.into_object(py);

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
