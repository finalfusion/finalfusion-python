use std::cell::RefCell;
use std::rc::Rc;

use finalfusion::vocab::{NGramIndices, SubwordIndices, Vocab, VocabWrap, WordIndex};
use pyo3::class::sequence::PySequenceProtocol;
use pyo3::exceptions::{IndexError, KeyError, ValueError};
use pyo3::prelude::*;
use pyo3::{PyIterProtocol, PyMappingProtocol};

use crate::iter::PyVocabIterator;
use crate::EmbeddingsWrap;

type NGramIndex = (String, Option<usize>);

/// finalfusion vocab.
#[pyclass(name=Vocab)]
pub struct PyVocab {
    embeddings: Rc<RefCell<EmbeddingsWrap>>,
}

impl PyVocab {
    pub fn new(embeddings: Rc<RefCell<EmbeddingsWrap>>) -> Self {
        PyVocab { embeddings }
    }
}

#[pymethods]
impl PyVocab {
    #[args(default = "Python::acquire_gil().python().None()")]
    fn get(&self, key: &str, default: PyObject) -> Option<PyObject> {
        let embeds = self.embeddings.borrow();
        let gil = pyo3::Python::acquire_gil();
        let idx = embeds.vocab().idx(key).map(|idx| match idx {
            WordIndex::Word(idx) => idx.to_object(gil.python()),
            WordIndex::Subword(indices) => indices.to_object(gil.python()),
        });
        if !default.is_none() && idx.is_none() {
            return Some(default);
        }
        idx
    }

    fn ngram_indices(&self, word: &str) -> PyResult<Option<Vec<NGramIndex>>> {
        let embeds = self.embeddings.borrow();
        Ok(match embeds.vocab() {
            VocabWrap::FastTextSubwordVocab(inner) => inner.ngram_indices(word),
            VocabWrap::BucketSubwordVocab(inner) => inner.ngram_indices(word),
            VocabWrap::ExplicitSubwordVocab(inner) => inner.ngram_indices(word),
            VocabWrap::SimpleVocab(_) => {
                return Err(ValueError::py_err(
                    "querying n-gram indices is not supported for this vocabulary",
                ))
            }
        })
    }

    fn subword_indices(&self, word: &str) -> PyResult<Option<Vec<usize>>> {
        let embeds = self.embeddings.borrow();
        match embeds.vocab() {
            VocabWrap::FastTextSubwordVocab(inner) => Ok(inner.subword_indices(word)),
            VocabWrap::BucketSubwordVocab(inner) => Ok(inner.subword_indices(word)),
            VocabWrap::ExplicitSubwordVocab(inner) => Ok(inner.subword_indices(word)),
            VocabWrap::SimpleVocab(_) => Err(ValueError::py_err(
                "querying subwords' indices is not supported for this vocabulary",
            )),
        }
    }
}

impl PyVocab {
    fn str_to_indices(&self, query: &str) -> PyResult<WordIndex> {
        let embeds = self.embeddings.borrow();
        embeds
            .vocab()
            .idx(query)
            .ok_or_else(|| KeyError::py_err(format!("key not found: '{}'", query)))
    }

    fn validate_and_convert_isize_idx(&self, mut idx: isize) -> PyResult<usize> {
        let embeds = self.embeddings.borrow();
        let vocab = embeds.vocab();
        if idx < 0 {
            idx += vocab.words_len() as isize;
        }

        if idx >= vocab.words_len() as isize || idx < 0 {
            Err(IndexError::py_err("list index out of range"))
        } else {
            Ok(idx as usize)
        }
    }
}

#[pyproto]
impl PyMappingProtocol for PyVocab {
    fn __getitem__(&self, query: PyObject) -> PyResult<PyObject> {
        let embeds = self.embeddings.borrow();
        let vocab = embeds.vocab();
        let gil = Python::acquire_gil();
        if let Ok(idx) = query.extract::<isize>(gil.python()) {
            let idx = self.validate_and_convert_isize_idx(idx)?;
            return Ok((&vocab.words()[idx]).into_py(gil.python()));
        }

        if let Ok(query) = query.extract::<String>(gil.python()) {
            return self.str_to_indices(&query).map(|idx| match idx {
                WordIndex::Subword(indices) => indices.into_py(gil.python()),
                WordIndex::Word(idx) => idx.into_py(gil.python()),
            });
        }

        Err(KeyError::py_err("key must be integer or string"))
    }
}

#[pyproto]
impl PyIterProtocol for PyVocab {
    fn __iter__(slf: PyRefMut<Self>) -> PyResult<PyVocabIterator> {
        Ok(PyVocabIterator::new(slf.embeddings.clone(), 0))
    }
}

#[pyproto]
impl PySequenceProtocol for PyVocab {
    fn __len__(&self) -> PyResult<usize> {
        let embeds = self.embeddings.borrow();
        Ok(embeds.vocab().words_len())
    }

    fn __contains__(&self, word: String) -> PyResult<bool> {
        let embeds = self.embeddings.borrow();
        Ok(embeds
            .vocab()
            .idx(&word)
            .and_then(|word_idx| word_idx.word())
            .is_some())
    }
}
