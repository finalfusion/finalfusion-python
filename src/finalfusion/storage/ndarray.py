"""
Finalfusion storage
"""

import struct
from os import PathLike
from typing import BinaryIO, Tuple, Union

import numpy as np

from finalfusion.io import ChunkIdentifier, TypeId, FinalfusionFormatError, find_chunk, \
    _pad_float32, _read_required_binary, _write_binary
from finalfusion.storage.storage import Storage


class NdArray(np.ndarray, Storage):
    """
    Array storage.

    Wraps an numpy matrix, either in-memory or memory-mapped.
    """
    def __new__(cls, array: np.ndarray):
        """
        Construct a new NdArray storage.

        Parameters
        ----------
        array : np.ndarray
            The storage buffer.

        Raises
        ------
        TypeError
            If the array is not a 2-dimensional float32 array.
        """
        if array.dtype != np.float32 or array.ndim != 2:
            raise TypeError("expected 2-d float32 array")
        return array.view(cls)

    @classmethod
    def load(cls, file: BinaryIO, mmap: bool = False) -> 'NdArray':
        return cls.mmap_chunk(file) if mmap else cls.read_chunk(file)

    @staticmethod
    def chunk_identifier():
        return ChunkIdentifier.NdArray

    @staticmethod
    def read_chunk(file: BinaryIO) -> 'NdArray':
        rows, cols = NdArray._read_array_header(file)
        array = np.fromfile(file=file, count=rows * cols, dtype=np.float32)
        array = np.reshape(array, (rows, cols))
        return NdArray(array)

    @property
    def shape(self) -> Tuple[int, int]:
        return super().shape

    @staticmethod
    def mmap_chunk(file: BinaryIO) -> 'NdArray':
        rows, cols = NdArray._read_array_header(file)
        offset = file.tell()
        file.seek(rows * cols * struct.calcsize('f'), 1)
        return NdArray(
            np.memmap(file.name,
                      dtype=np.float32,
                      mode='r',
                      offset=offset,
                      shape=(rows, cols)))

    @staticmethod
    def _read_array_header(file: BinaryIO) -> Tuple[int, int]:
        """
        Helper method to read the header of an NdArray chunk.

        The method reads the shape tuple, verifies the TypeId and seeks the file to the start
        of the array. The shape tuple is returned.

        Parameters
        ----------
        file : BinaryIO
            finalfusion file with a storage at the start of a NdArray chunk.

        Returns
        -------
        shape : Tuple[int, int]
            Shape of the storage.

        Raises
        ------
        FinalfusionFormatError
            If the TypeId does not match TypeId.f32
        """
        rows, cols = _read_required_binary(file, "<QI")
        type_id = TypeId(_read_required_binary(file, "<I")[0])
        if TypeId.f32 != type_id:
            raise FinalfusionFormatError(
                f"Invalid Type, expected {TypeId.f32}, got {type_id}")
        file.seek(_pad_float32(file.tell()), 1)
        return rows, cols

    def write_chunk(self, file: BinaryIO):
        _write_binary(file, "<I", int(self.chunk_identifier()))
        padding = _pad_float32(file.tell())
        chunk_len = struct.calcsize("<QII") + padding + struct.calcsize(
            f'<{self.size}f')
        # pylint: disable=unpacking-non-sequence
        rows, cols = self.shape
        _write_binary(file, "<QQII", chunk_len, rows, cols, int(TypeId.f32))
        _write_binary(file, f"{padding}x")
        self.tofile(file)

    def __getitem__(self, key):
        if isinstance(key, slice):
            return super().__getitem__(key)
        return super().__getitem__(key).view(np.ndarray)


def load_ndarray(file: Union[str, bytes, int, PathLike],
                 mmap: bool = False) -> NdArray:
    """
    Load an array chunk from the given file.

    Parameters
    ----------
    file: str, bytes, int, PathLike
        Finalfusion file with a ndarray chunk.
    mmap : bool
        Toggles memory mapping the array buffer as read only.

    Returns
    -------
    storage : NdArray
        The NdArray storage from the file.

    Raises
    ------
    ValueError
        If the file did not contain and NdArray chunk.
    """
    with open(file, "rb") as inf:
        chunk = find_chunk(inf, [ChunkIdentifier.NdArray])
        if chunk is None:
            raise ValueError("File did not contain a NdArray chunk")
        if chunk == ChunkIdentifier.NdArray:
            if mmap:
                return NdArray.mmap_chunk(inf)
            return NdArray.read_chunk(inf)
        raise ValueError(f"unknown storage type: {chunk}")
