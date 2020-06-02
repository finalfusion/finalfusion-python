"""
Quantized finalfusion storage

This module contains the QuantizedArray storage type and the PQ quantizer.
Quantized storages offer a memory-for-speed trade-off and drastically reduce
the size of embedding matrices.
"""

import struct
import sys
from os import PathLike
from typing import Tuple, Optional, Union, BinaryIO, Iterator, Sequence, cast

import numpy as np

from finalfusion.io import _pad_float32, ChunkIdentifier, TypeId, FinalfusionFormatError, \
    find_chunk, _read_required_binary, _write_binary, _serialize_array_as_le, _read_array_as_native
from finalfusion.storage.storage import Storage


class PQ:
    """
    Product Quantizer

    Product Quantizers are vector quantizers which decompose high dimensional vector
    spaces into subspaces. Each of these subspaces is a slice of the the original
    vector space. Embeddings are quantized by assigning their ith slice to the closest
    centroid.

    Product Quantizers can reconstruct vectors by concatenating the slices of the
    quantized vector.
    """
    def __init__(self, quantizers: np.ndarray,
                 projection: Optional[np.ndarray]):
        """
        Initializes a Product Quantizer.

        Parameters
        ----------
        quantizers : np.ndarray
            3-d ndarray with dtype uint8
        projection : np.ndarray, optional
            Projection matrix, must be a square matrix with shape
            `[reconstructed_len, reconstructed_len]`

        Raises
        ------
        AssertionError
            If the projection shape does not match the `reconstructed_len`
        """
        self._quantizers = quantizers
        self._reconstructed_len = cast(
            int, quantizers.shape[0] * quantizers.shape[2])
        if projection is not None:
            assert projection.shape[
                0] == self._reconstructed_len == projection.shape[1]
        self._projection = projection

    @property
    def n_centroids(self) -> int:
        """
        Number of centroids per quantizer.

        Returns
        -------
        n_centroids : int
             The number of centroids per quantizer.
        """
        centroids = self._quantizers.shape[1]  # type: int
        return centroids

    @property
    def projection(self) -> Optional[np.ndarray]:
        """
        Projection matrix.

        Returns
        -------
        projection : np.ndarray, optional
            Projection Matrix (2-d numpy array with datatype float32) or None.
        """
        return self._projection

    @property
    def reconstructed_len(self) -> int:
        """
        Reconstructed length.

        Returns
        -------
        reconstructed_len : int
            Length of the reconstructed vectors.
        """
        return self._reconstructed_len

    @property
    def subquantizers(self) -> np.ndarray:
        """
        Get the quantizers.

        Returns a 3-d array with shape
        `quantizers * n_centroids * reconstructed_len / quantizers`

        Returns
        -------
        quantizers : np.ndarray
            3-d np.ndarray with dtype=np.uint8
        @return: 3d tensor of quantizers
        """
        return self._quantizers

    def reconstruct(self, quantized: np.ndarray,
                    out: np.ndarray = None) -> np.ndarray:
        """
        Reconstruct vectors.

        Input

        Parameters
        ----------
        quantized : np.ndarray
            Batch of quantized vectors. 2-d np.ndarray with integers required.
        out : np.ndarray, optional
            2-d np.ndarray to write the output into.

        Returns
        -------
        out : np.ndarray
            Batch of reconstructed vectors.

        Raises
        ------
        AssertionError
            If `out` is passed and its last dimension does not match `reconstructed_len` or its
            first `n-1` dimensions do not match the first `n-1` dimensions of `quantized`.
        """
        quantizers_range = np.arange(self._quantizers.shape[0])
        if out is None:
            if quantized.ndim == 1:
                out_shape = self._reconstructed_len  # type: Union[int, Sequence[int]]
            else:
                first_dims = quantized.shape[:-1]  # type: Sequence[int]
                out_shape = (*first_dims, self._reconstructed_len)
            out = self._quantizers[quantizers_range, quantized].reshape(
                out_shape)
        else:
            assert out.shape[:-1] == quantized.shape[:-1]
            assert out.shape[-1] == self._reconstructed_len
            out[:] = self._quantizers[quantizers_range, quantized].reshape(
                out.shape)
        if self.projection is not None:
            out.dot(self.projection.T, out=out)
        return out


class QuantizedArray(Storage):
    """
    QuantizedArray storage.

    QuantizedArrays support slicing, indexing with integers, lists of integers and arbitrary
    dimensional integer arrays. Slicing a QuantizedArray returns a new QuantizedArray but does not
    copy any buffers.

    QuantizedArrays offer two ways of indexing:

    1. :meth:`QuantizedArray.__getitem__`:
        * passing a slice returns a new view of the QuantizedArray.
        * passing an integer returns a single embedding, lists and arrays return ndims + 1
          dimensional embeddings.
    2. :meth:`QuantizedArray.embedding`:
        * embeddings can be written to an output buffer.
        * passing a slice returns a matrix holding **reconstructed** embeddings.
        * otherwise, this method behaves like :meth:`~QuantizedArray.__getitem__`

    A QuantizedArray can be treated as :class:`numpy.ndarray` through :func:`numpy.asarray`.
    This restores the original matrix and copies into a **new** buffer.

    Using common numpy functions on a QuantizedArray will produce a regular
    :class:`~numpy.ndarray` in the process and is therefore an expensive operation.
    """
    def __init__(self, pq: PQ, quantized_embeddings: np.ndarray,
                 norms: Optional[np.ndarray]):
        """
        Initialize a QuantizedArray.

        Parameters
        ----------
        pq : PQ
            A product quantizer
        quantized_embeddings : numpy.ndarray
            The quantized embeddings
        norms : numpy.ndarray, optional
            Optional norms corresponding to the quantized embeddings. Reconstructed embeddings are
            scaled by their norm.
        """
        self._quantizer = pq
        self._quantized_embeddings = quantized_embeddings
        self._norms = norms

    @property
    def shape(self) -> Tuple[int, int]:
        return self._quantized_embeddings.shape[
            0], self._quantizer.reconstructed_len

    def embedding(self, key, out: np.ndarray = None) -> np.ndarray:
        """
        Get embeddings.

        * if ``key`` is an integer, a single reconstructed embedding is returned.
        * if ``key`` is a list of integers or a slice, a matrix of reconstructed embeddings is
          returned.
        * if ``key`` is an n-dimensional array, a tensor with reconstructed embeddings is returned.
          This tensor has one new axis in the last dimension containing the embeddings.

        If ``out`` is passed, the reconstruction is written to this buffer. ``out.shape`` needs to
        match the dimensions described above.

        Parameters
        ----------
        key : int, list, numpy.ndarray, slice
            Key specifying which embeddings to retrieve.
        out : numpy.ndarray
            Array to reconstruct the embeddings into.

        Returns
        -------
        reconstruction : numpy.ndarray
            The reconstructed embedding or embeddings.
        """
        quantized = self._quantized_embeddings[key]
        out = self._quantizer.reconstruct(quantized, out=out)
        if self._norms is None:
            return out
        return np.multiply(self._norms[key, None], out, out=out)

    @property
    def quantized_len(self) -> int:
        """
        Length of the quantized embeddings.

        Returns
        -------
        quantized_len : int
            Length of quantized embeddings.
        """
        q_len = self._quantized_embeddings.shape[1]  # type: int
        return q_len

    @property
    def quantizer(self):
        """
        Get the quantizer.

        Returns
        -------
        pq : PQ
            The Product Quantizer.
        """
        return self._quantizer

    def __getitem__(self, key) -> Union[np.ndarray, 'QuantizedArray']:
        if key is None:
            raise TypeError("None is not a valid key.")
        if isinstance(key, slice):
            quantizer = self.quantizer
            sliced_embeds = self._quantized_embeddings[key]
            norms = None
            if self._norms is not None:
                norms = self._norms[key]
            return QuantizedArray(quantizer, sliced_embeds, norms)
        return self.embedding(key)

    def __iter__(self) -> Iterator[np.ndarray]:
        return map(self._quantizer.reconstruct, self._quantized_embeddings)

    def __len__(self) -> int:
        return len(self._quantized_embeddings)

    def __array__(self) -> np.ndarray:
        if self._norms is None:
            return self._quantizer.reconstruct(self._quantized_embeddings)
        return self._norms[:, None] * self._quantizer.reconstruct(
            self._quantized_embeddings)

    @classmethod
    def load(cls, file: BinaryIO, mmap=False) -> 'QuantizedArray':
        return cls.mmap_chunk(file) if mmap else cls.read_chunk(file)

    @staticmethod
    def read_chunk(file: BinaryIO) -> 'QuantizedArray':
        quantizer, embeds_shape, norms = QuantizedArray._read_quantized_header(
            file)
        n_embeddings, quantized_len = embeds_shape
        quantized_embeddings = _read_array_as_native(
            file, np.uint8, n_embeddings * quantized_len)
        quantized_embeddings = quantized_embeddings.reshape(embeds_shape)
        return QuantizedArray(quantizer, quantized_embeddings, norms)

    @staticmethod
    def mmap_chunk(file: BinaryIO) -> 'QuantizedArray':
        if sys.byteorder == "big":
            raise NotImplementedError(
                "Memmapping arrays is not supported on big endian platforms")
        quantizer, embeds_shape, norms = QuantizedArray._read_quantized_header(
            file)
        n_embeddings, quantized_len = embeds_shape
        offset = file.tell()
        file.seek(n_embeddings * quantized_len, 1)
        quantized_embeddings = np.memmap(file.name,
                                         dtype=np.uint8,
                                         mode='r',
                                         offset=offset,
                                         shape=embeds_shape)
        return QuantizedArray(quantizer, quantized_embeddings, norms)

    def write_chunk(self, file: BinaryIO):
        _write_binary(file, "<I", int(self.chunk_identifier()))
        padding = _pad_float32(file.tell())
        chunk_len = struct.calcsize("<IIIIIQII") + padding
        proj = self._quantizer.projection is not None
        if proj:
            chunk_len += struct.calcsize(
                f"<{pow(self._quantizer.reconstructed_len, 2)}f")
        chunk_len += struct.calcsize(f"<{self._quantizer.subquantizers.size}f")
        norms = self._norms is not None
        if self._norms is not None:
            chunk_len += struct.calcsize(f"<{self._norms.size}f")
        chunk_len += self._quantized_embeddings.size
        chunk_header = (chunk_len, proj, norms, self.quantized_len,
                        self.shape[1], self.quantizer.n_centroids,
                        self.shape[0], int(TypeId.u8), int(TypeId.f32))
        _write_binary(file, "<QIIIIIQII", *chunk_header)
        file.write(struct.pack(f"{padding}x"))
        if proj:
            _serialize_array_as_le(file, self.quantizer.projection)
        _serialize_array_as_le(file, self.quantizer.subquantizers)
        if norms:
            _serialize_array_as_le(file, self._norms)
        self._quantized_embeddings.tofile(file)

    @staticmethod
    def chunk_identifier() -> ChunkIdentifier:
        return ChunkIdentifier.QuantizedArray

    @staticmethod
    def _read_quantized_header(
            file: BinaryIO
    ) -> Tuple[PQ, Tuple[int, int], Optional[np.ndarray]]:
        """
        Helper method to read the header of a quantized array chunk.
        Returns a tuple containing PQ, quantized_shape and optional norms.
        """
        projection = _read_required_binary(file, '<I')[0] != 0
        read_norms = _read_required_binary(file, '<I')[0] != 0
        quantized_len = _read_required_binary(file, '<I')[0]
        reconstructed_len = _read_required_binary(file, '<I')[0]
        n_centroids = _read_required_binary(file, '<I')[0]
        n_embeddings = _read_required_binary(file, '<Q')[0]
        assert reconstructed_len % quantized_len == 0
        type_id = _read_required_binary(file, '<I')[0]
        if int(TypeId.u8) != type_id:
            raise FinalfusionFormatError(
                f"Invalid Type, expected {str(TypeId.u8)}, got {type_id}")
        type_id = _read_required_binary(file, '<I')[0]
        if int(TypeId.f32) != type_id:
            raise FinalfusionFormatError(
                f"Invalid Type, expected {str(TypeId.f32)}, got {type_id}")
        file.seek(_pad_float32(file.tell()), 1)
        if projection:
            projection = _read_array_as_native(file, np.float32,
                                               reconstructed_len**2)
            projection_shape = (reconstructed_len, reconstructed_len)
            projection = projection.reshape(projection_shape)
        else:
            projection = None
        quantizer_shape = (quantized_len, n_centroids,
                           reconstructed_len // quantized_len)
        quantizers_size = quantized_len * n_centroids * (reconstructed_len //
                                                         quantized_len)
        quantizers = _read_array_as_native(file, np.float32, quantizers_size)
        quantizers = quantizers.reshape(quantizer_shape)
        if read_norms:
            norms = _read_array_as_native(file, np.float32, n_embeddings)
        else:
            norms = None
        quantizer = PQ(quantizers, projection)
        return quantizer, (n_embeddings, quantized_len), norms


def load_quantized_array(file: Union[str, bytes, int, PathLike],
                         mmap: bool = False) -> QuantizedArray:
    """
    Load a quantized array chunk from the given file.

    Parameters
    ----------
    file : str, bytes, int, PathLike
        Finalfusion file with a quantized array chunk.
    mmap : bool
        Toggles memory mapping the array buffer as read only.

    Returns
    -------
    storage : QuantizedArray
        The QuantizedArray storage from the file.

    Raises
    ------
    ValueError
        If the file did not contain a QuantizedArray chunk.
    """
    with open(file, "rb") as inf:
        chunk = find_chunk(inf, [ChunkIdentifier.QuantizedArray])
        if chunk is None:
            raise ValueError("File did not contain a QuantizedArray chunk")
        if chunk == ChunkIdentifier.QuantizedArray:
            return QuantizedArray.load(inf, mmap)
        raise ValueError(f"unknown storage type: {chunk}")


__all__ = ['QuantizedArray', 'PQ', 'load_quantized_array']
