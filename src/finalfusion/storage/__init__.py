"""
Finalfusion Storage
"""

from finalfusion.io import ChunkIdentifier, find_chunk
from finalfusion.storage.storage import Storage
from finalfusion.storage.ndarray import NdArray, load_ndarray


def load_storage(path: str, mmap: bool = False) -> Storage:
    """
    Load any vocabulary from a finalfusion file.

    Loads the first known vocabulary from a finalfusion file.

    Parameters
    ----------
    path : str
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
    with open(path, "rb") as file:
        chunk = find_chunk(
            file, [ChunkIdentifier.NdArray, ChunkIdentifier.QuantizedArray])
        if chunk is None:
            raise ValueError('File did not contain a storage')
        if chunk == ChunkIdentifier.NdArray:
            if mmap:
                return NdArray.mmap_chunk(file)
            return NdArray.read_chunk(file)
        raise NotImplementedError('Storage type is not yet supported.')
