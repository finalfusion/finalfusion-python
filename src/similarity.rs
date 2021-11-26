use pyo3::class::basic::PyObjectProtocol;
use pyo3::prelude::*;

/// A word and its similarity to a query word.
///
/// The similarity is normally a value between -1 (opposite
/// vectors) and 1 (identical vectors).
#[pyclass(name = "WordSimilarity")]
pub struct PyWordSimilarity {
    #[pyo3(get)]
    word: String,

    #[pyo3(get)]
    similarity: f32,
}

impl PyWordSimilarity {
    pub fn new(word: String, similarity: f32) -> Self {
        PyWordSimilarity { word, similarity }
    }
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
