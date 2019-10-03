use std::cell::RefCell;
use std::rc::Rc;

use finalfusion::chunks::vocab::{NGramIndices, SubwordIndices, VocabWrap, WordIndex};
use finalfusion::prelude::*;
use pyo3::class::sequence::PySequenceProtocol;
use pyo3::exceptions;
use pyo3::prelude::*;

use crate::EmbeddingsWrap;

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
    fn item_to_indices(&self, key: String) -> Option<PyObject> {
        let embeds = self.embeddings.borrow();

        embeds.vocab().idx(key.as_str()).map(|idx| {
            let gil = pyo3::Python::acquire_gil();
            match idx {
                WordIndex::Word(idx) => [idx].to_object(gil.python()),
                WordIndex::Subword(indices) => indices.to_object(gil.python()),
            }
        })
    }

    fn ngram_indices(&self, word: &str) -> PyResult<Option<Vec<(String, usize)>>> {
        let embeds = self.embeddings.borrow();
        match embeds.vocab() {
            VocabWrap::FastTextSubwordVocab(inner) => Ok(inner.ngram_indices(word)),
            VocabWrap::FinalfusionSubwordVocab(inner) => Ok(inner.ngram_indices(word)),
            VocabWrap::SimpleVocab(_) => Err(exceptions::ValueError::py_err(
                "querying n-gram indices is not supported for this vocabulary",
            )),
        }
    }

    fn subword_indices(&self, word: &str) -> PyResult<Option<Vec<usize>>> {
        let embeds = self.embeddings.borrow();
        match embeds.vocab() {
            VocabWrap::FastTextSubwordVocab(inner) => Ok(inner.subword_indices(word)),
            VocabWrap::FinalfusionSubwordVocab(inner) => Ok(inner.subword_indices(word)),
            VocabWrap::SimpleVocab(_) => Err(exceptions::ValueError::py_err(
                "querying subwords' indices is not supported for this vocabulary",
            )),
        }
    }
}

#[pyproto]
impl PySequenceProtocol for PyVocab {
    fn __len__(&self) -> PyResult<usize> {
        let embeds = self.embeddings.borrow();
        Ok(embeds.vocab().words_len())
    }

    fn __getitem__(&self, idx: isize) -> PyResult<String> {
        let embeds = self.embeddings.borrow();
        let words = embeds.vocab().words();

        if idx >= words.len() as isize || idx < 0 {
            Err(exceptions::IndexError::py_err("list index out of range"))
        } else {
            Ok(words[idx as usize].clone())
        }
    }

    fn __contains__(&self, word: String) -> PyResult<bool> {
        let embeds = self.embeddings.borrow();
        Ok(embeds
            .vocab()
            .idx(&word)
            .map(|word_idx| match word_idx {
                WordIndex::Word(_) => true,
                WordIndex::Subword(_) => false,
            })
            .unwrap_or(false))
    }
}
