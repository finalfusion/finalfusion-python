"""
Finalfusion Storage
"""
from os import PathLike
from typing import Union

from finalfusion.io import ChunkIdentifier, find_chunk
from finalfusion.storage.storage import Storage
from finalfusion.storage.ndarray import NdArray, load_ndarray
from finalfusion.storage.quantized import QuantizedArray, load_quantized_array


def load_storage(file: Union[str, bytes, int, PathLike],
                 mmap: bool = False) -> Storage:
    """
    Load any vocabulary from a finalfusion file.

    Loads the first known vocabulary from a finalfusion file.

    Parameters
    ----------
    file : str
        Path to finalfusion file containing a storage chunk.
    mmap : bool
        Toggles memory mapping the storage buffer as read-only.

    Returns
    -------
    storage : Storage
        First finalfusion Storage in the file.

    Raises
    ------
    ValueError
         If the file did not contain a vocabulary.
    """
    with open(file, "rb") as inf:
        chunk = find_chunk(
            inf, [ChunkIdentifier.NdArray, ChunkIdentifier.QuantizedArray])
        if chunk is None:
            raise ValueError('File did not contain a storage')
        if chunk == ChunkIdentifier.NdArray:
            if mmap:
                return NdArray.mmap_chunk(inf)
            return NdArray.read_chunk(inf)
        if chunk == ChunkIdentifier.QuantizedArray:
            if mmap:
                return QuantizedArray.mmap_chunk(inf)
            return QuantizedArray.read_chunk(inf)
        raise NotImplementedError('Storage type is not yet supported.')


__all__ = [
    'Storage', 'load_storage', 'QuantizedArray', 'load_quantized_array',
    'NdArray', 'load_ndarray'
]
