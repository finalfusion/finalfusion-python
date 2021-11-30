use std::sync::{Arc, RwLock};

use finalfusion::storage::{Storage, StorageView, StorageWrap};
use ndarray::Array2;
use numpy::{PyArray1, PyArray2, ToPyArray};
use pyo3::class::sequence::PySequenceProtocol;
use pyo3::exceptions;
use pyo3::prelude::*;

use crate::EmbeddingsWrap;

/// finalfusion storage.
#[pyclass(name = "Storage")]
pub struct PyStorage {
    embeddings: Arc<RwLock<EmbeddingsWrap>>,
}

impl PyStorage {
    pub fn new(embeddings: Arc<RwLock<EmbeddingsWrap>>) -> Self {
        PyStorage { embeddings }
    }

    /// Copy storage to an array.
    ///
    /// This should only be used for storage types that do not provide
    /// an ndarray view that can be copied trivially, such as quantized
    /// storage.
    fn copy_storage_to_array(storage: &dyn Storage) -> Array2<f32> {
        let (rows, dims) = storage.shape();

        let mut array = Array2::<f32>::zeros((rows, dims));
        for idx in 0..rows {
            array.row_mut(idx).assign(&storage.embedding(idx).view());
        }

        array
    }
}

#[pymethods]
impl PyStorage {
    /// Copy the entire embeddings matrix.
    fn matrix_copy(&self) -> Py<PyArray2<f32>> {
        let embeddings = self.embeddings.read().unwrap();

        use EmbeddingsWrap::*;
        let gil = pyo3::Python::acquire_gil();
        let matrix_view = match &*embeddings {
            View(e) => e.storage().view(),
            NonView(e) => match e.storage() {
                StorageWrap::MmapArray(mmap) => mmap.view(),
                StorageWrap::NdArray(array) => array.view(),
                StorageWrap::QuantizedArray(quantized) => {
                    let array = Self::copy_storage_to_array(quantized.as_ref());
                    return array.to_pyarray(gil.python()).to_owned();
                }
                StorageWrap::MmapQuantizedArray(quantized) => {
                    let array = Self::copy_storage_to_array(quantized);
                    return array.to_pyarray(gil.python()).to_owned();
                }
            },
        };

        matrix_view.to_pyarray(gil.python()).to_owned()
    }

    /// Get the shape of the storage.
    fn shape(&self) -> (usize, usize) {
        let embeddings = self.embeddings.read().unwrap();
        embeddings.storage().shape()
    }
}

#[pyproto]
impl PySequenceProtocol for PyStorage {
    fn __len__(&self) -> PyResult<usize> {
        let embeds = self.embeddings.read().unwrap();
        Ok(embeds.storage().shape().0)
    }

    fn __getitem__(&self, idx: isize) -> PyResult<Py<PyArray1<f32>>> {
        let embeds = self.embeddings.read().unwrap();
        let storage = embeds.storage();

        if idx >= storage.shape().0 as isize || idx < 0 {
            Err(exceptions::PyIndexError::new_err("list index out of range"))
        } else {
            let gil = Python::acquire_gil();
            Ok(storage
                .embedding(idx as usize)
                .into_owned()
                .to_pyarray(gil.python())
                .to_owned())
        }
    }
}
