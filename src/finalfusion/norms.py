"""
Norms module.
"""

import struct
from os import PathLike
import sys
from typing import BinaryIO, Union, List, Collection

import numpy as np

from finalfusion.io import Chunk, ChunkIdentifier, find_chunk, TypeId, FinalfusionFormatError, \
    _pad_float32, _write_binary, _read_required_binary, _serialize_array_as_le


class Norms(np.ndarray, Chunk, Collection[float]):
    """
    Norms Chunk.

    Norms subclass `numpy.ndarray`, all typical numpy operations are available.
    """
    def __new__(cls, array: np.ndarray):
        """
        Construct new Norms.

        Parameters
        ----------
        array : numpy.ndarray
            Norms array.

        Returns
        -------
        norms : Norms
            The norms.

        Raises
        ------
        AssertionError
            If array is not a 1-d array of float32 values.
        """
        if not np.issubdtype(array.dtype,
                             np.float32) != np.float32 or array.ndim != 1:
            raise TypeError(
                f"expected 1-d float32 array, not {array.ndim}-d {array.dtype}"
            )
        return array.view(cls)

    @staticmethod
    def chunk_identifier() -> ChunkIdentifier:
        return ChunkIdentifier.NdNorms

    @staticmethod
    def read_chunk(file: BinaryIO) -> 'Norms':
        n_norms, dtype = _read_required_binary(file, "<QI")
        type_id = TypeId(dtype)
        if TypeId.f32 != type_id:
            raise FinalfusionFormatError(
                f"Invalid Type, expected {TypeId.f32}, got {str(type_id)}")
        padding = _pad_float32(file.tell())
        file.seek(padding, 1)
        array = np.fromfile(file=file, count=n_norms, dtype=np.float32)
        if sys.byteorder == "big":
            array.byteswap(inplace=True)
        return Norms(array)

    def write_chunk(self, file: BinaryIO):
        _write_binary(file, "<I", int(self.chunk_identifier()))
        padding = _pad_float32(file.tell())
        chunk_len = struct.calcsize("QI") + padding + struct.calcsize(
            f"<{self.size}f")
        _write_binary(file, f"<QQI{padding}x", chunk_len, self.size,
                      int(TypeId.f32))
        _serialize_array_as_le(file, self)

    def __getitem__(self, key: Union[int, slice, List[int], np.ndarray]
                    ) -> Union[float, 'Norms']:
        if isinstance(key, slice):
            return Norms(super().__getitem__(key))
        norm = super().__getitem__(key)  # type: float
        return norm


def load_norms(file: Union[str, bytes, int, PathLike]):
    """
    Load Norms from a finalfusion file.

    Loads the first Norms chunk from a finalfusion file.

    Parameters
    ----------
    file: str, bytes, int, PathLike
        Path to finalfusion file containing a Norms chunk.

    Returns
    -------
    norms : Norms
        First finalfusion Norms in the file.

    Raises
    ------
    ValueError
        If the file did not contain norms.
    """
    with open(file, "rb") as inf:
        chunk = find_chunk(inf, [ChunkIdentifier.NdNorms])
        if chunk is None:
            raise ValueError('File did not contain norms.')
        if chunk == ChunkIdentifier.NdNorms:
            return Norms.read_chunk(inf)
        raise ValueError(f"Unexpected chunk: {str(chunk)}")


__all__ = ['Norms', 'load_norms']
