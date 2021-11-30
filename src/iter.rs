use std::sync::{Arc, RwLock};

use finalfusion::vocab::Vocab;
use numpy::{IntoPyArray, PyArray1};
use pyo3::class::iter::PyIterProtocol;
use pyo3::prelude::*;

use crate::EmbeddingsWrap;

#[pyclass(name = "EmbeddingIterator")]
pub struct PyEmbeddingIterator {
    embeddings: Arc<RwLock<EmbeddingsWrap>>,
    idx: usize,
}

impl PyEmbeddingIterator {
    pub fn new(embeddings: Arc<RwLock<EmbeddingsWrap>>, idx: usize) -> Self {
        PyEmbeddingIterator { embeddings, idx }
    }
}

#[pyproto]
impl PyIterProtocol for PyEmbeddingIterator {
    fn __iter__(slf: PyRefMut<Self>) -> PyResult<Py<PyEmbeddingIterator>> {
        Ok(slf.into())
    }

    fn __next__(mut slf: PyRefMut<Self>) -> PyResult<Option<PyEmbedding>> {
        let slf = &mut *slf;

        let embeddings = slf.embeddings.read().unwrap();
        let vocab = embeddings.vocab();

        if slf.idx < vocab.words_len() {
            let word = vocab.words()[slf.idx].to_string();
            let embed = embeddings.storage().embedding(slf.idx);
            let norm = embeddings.norms().map(|n| n[slf.idx]).unwrap_or(1.);

            slf.idx += 1;

            let gil = pyo3::Python::acquire_gil();
            Ok(Some(PyEmbedding {
                word,
                embedding: embed.into_owned().into_pyarray(gil.python()).to_owned(),
                norm,
            }))
        } else {
            Ok(None)
        }
    }
}

/// A word and its embedding and embedding norm.
#[pyclass(name = "Embedding")]
pub struct PyEmbedding {
    embedding: Py<PyArray1<f32>>,
    norm: f32,
    word: String,
}

#[pymethods]
impl PyEmbedding {
    /// Get the embedding.
    #[getter]
    pub fn get_embedding(&self) -> Py<PyArray1<f32>> {
        let gil = Python::acquire_gil();
        self.embedding.clone_ref(gil.python())
    }

    /// Get the word.
    #[getter]
    pub fn get_word(&self) -> &str {
        &self.word
    }

    /// Get the norm.
    #[getter]
    pub fn get_norm(&self) -> f32 {
        self.norm
    }
}

#[pyclass(name = "VocabIterator")]
pub struct PyVocabIterator {
    embeddings: Arc<RwLock<EmbeddingsWrap>>,
    idx: usize,
}

impl PyVocabIterator {
    pub fn new(embeddings: Arc<RwLock<EmbeddingsWrap>>, idx: usize) -> Self {
        PyVocabIterator { embeddings, idx }
    }
}

#[pyproto]
impl PyIterProtocol for PyVocabIterator {
    fn __iter__(slf: PyRefMut<Self>) -> PyResult<Py<PyVocabIterator>> {
        Ok(slf.into())
    }

    fn __next__(mut slf: PyRefMut<Self>) -> PyResult<Option<String>> {
        let slf = &mut *slf;

        let embeddings = slf.embeddings.read().unwrap();
        let vocab = embeddings.vocab();

        if slf.idx < vocab.words_len() {
            let word = vocab.words()[slf.idx].to_string();
            slf.idx += 1;
            Ok(Some(word))
        } else {
            Ok(None)
        }
    }
}
