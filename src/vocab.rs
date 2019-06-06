use std::cell::RefCell;
use std::rc::Rc;

use finalfusion::prelude::*;
use finalfusion::vocab::WordIndex;
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
    fn item_to_indices(&self, key: String) -> PyResult<PyObject> {
        let embeds = self.embeddings.borrow();

        embeds
            .vocab()
            .idx(key.as_str())
            .map(|idx| {
                let gil = pyo3::Python::acquire_gil();
                match idx {
                    WordIndex::Word(idx) => [idx].to_object(gil.python()),
                    WordIndex::Subword(indices) => indices.to_object(gil.python()),
                }
            })
            .ok_or_else(|| exceptions::KeyError::py_err("Unknown word or n-grams"))
    }
}

#[pyproto]
impl PySequenceProtocol for PyVocab {
    fn __len__(&self) -> PyResult<usize> {
        let embeds = self.embeddings.borrow();
        Ok(embeds.vocab().len())
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
}
