"""
Norms module.
"""

import struct

import numpy as np

from finalfusion.io import Chunk, ChunkIdentifier, find_chunk, TypeId, FinalfusionFormatError,\
    _pad_float32


class Norms(np.ndarray, Chunk):
    """
    Norms Chunk.

    Norms subclass `numpy.ndarray`, all typical numpy operations are available.
    """
    def __new__(cls, array: np.array):
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
        if array.dtype != np.float32 or array.ndim != 1:
            raise TypeError("expected 1-d float32 array")
        return array.view(cls)

    @staticmethod
    def chunk_identifier():
        return ChunkIdentifier.NdNorms

    @staticmethod
    def read_chunk(file) -> 'Norms':
        n_norms, dtype = Norms._read_binary(file, "<QI")
        type_id = TypeId(dtype)
        if TypeId.f32 != type_id:
            raise FinalfusionFormatError(
                f"Invalid Type, expected {TypeId.f32}, got {str(type_id)}")
        padding = _pad_float32(file.tell())
        file.seek(padding, 1)
        array = file.read(struct.calcsize("f") * n_norms)
        array = np.ndarray(buffer=array, shape=(n_norms, ), dtype=np.float32)
        return Norms(array)

    def write_chunk(self, file):
        Norms._write_binary(file, "<I", int(self.chunk_identifier()))
        padding = _pad_float32(file.tell())
        chunk_len = struct.calcsize("QI") + padding + struct.calcsize(
            f"<{self.size}f")
        Norms._write_binary(file, f"<QQI{padding}x", chunk_len, self.size,
                            int(TypeId.f32))
        self.tofile(file)

    def __getitem__(self, key):
        if isinstance(key, slice):
            return Norms(super().__getitem__(key))
        return super().__getitem__(key)


def load_norms(path: str):
    """
    Load Norms from a finalfusion file.

    Loads the first Norms chunk from a finalfusion file.

    Parameters
    ----------
    path : str
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
    with open(path, "rb") as file:
        chunk = find_chunk(file, [ChunkIdentifier.NdNorms])
        if chunk is None:
            raise ValueError('File did not contain norms.')
        if chunk == ChunkIdentifier.NdNorms:
            return Norms.read_chunk(file)
        raise ValueError(f"Unexpected chunk: {str(chunk)}")
