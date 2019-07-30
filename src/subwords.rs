use finalfusion::subword::{NGramsIndices, SubwordIndices};
use pyo3::prelude::*;
use pyo3::types::PyTuple;

#[pyclass(name=SuwbwordInfo)]
pub struct PySubwordInfo {
    word: String,
}

#[pymethods]
impl PySubwordInfo {
    #[new]
    fn __new__(obj: &PyRawObject, word_slice: &str) -> PyResult<()> {
        let word = word_slice.to_string();
        obj.init(PySubwordInfo { word });
        Ok(())
    }

    fn get_ngrams_indices(
        &self,
        min_n: usize,
        max_n: usize,
        buckets_exp: usize,
    ) -> PyResult<Vec<Py<PyTuple>>> {
        let gil = pyo3::Python::acquire_gil();
        Ok(self
            .word
            .ngrams_indices(min_n, max_n, buckets_exp)
            .into_iter()
            .map(|pair| pair.into_py(gil.python()))
            .collect())
    }

    fn get_subword_indices(
        &self,
        min_n: usize,
        max_n: usize,
        buckets_exp: usize,
    ) -> PyResult<Vec<u64>> {
        Ok(self.word.subword_indices(min_n, max_n, buckets_exp))
    }
}
