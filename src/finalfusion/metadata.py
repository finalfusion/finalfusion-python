"""
finalfusion metadata
"""
import struct
from os import PathLike
from typing import BinaryIO, Union

import toml

from finalfusion.io import Chunk, ChunkIdentifier, find_chunk, _read_required_binary,\
    _write_binary, FinalfusionFormatError


class Metadata(dict, Chunk):
    """
    Embeddings metadata

    Metadata can be used as a regular Python dict. For serialization, the contents need to be
    serializable through `toml.dumps`. Finalfusion assumes metadata to be a TOML formatted
    string.

    Examples
    --------
    >>> metadata = Metadata({'Some': 'value', 'number': 1})
    >>> metadata
    {'Some': 'value', 'number': 1}
    >>> metadata['Some']
    'value'
    >>> metadata['Some'] = 'other value'
    >>> metadata['Some']
    'other value'
    """
    @staticmethod
    def chunk_identifier() -> ChunkIdentifier:
        return ChunkIdentifier.Metadata

    @staticmethod
    def read_chunk(file: BinaryIO) -> 'Metadata':
        chunk_header_size = struct.calcsize("<IQ")
        # place the file before the chunk header since the chunk size for
        # metadata the number of bytes that we need to read
        file.seek(-chunk_header_size, 1)
        chunk_id, chunk_len = _read_required_binary(file, "<IQ")
        assert ChunkIdentifier(chunk_id) == Metadata.chunk_identifier()
        buf = file.read(chunk_len)
        if len(buf) != chunk_len:
            raise FinalfusionFormatError(
                f'Could not read {chunk_len} bytes from file')
        return Metadata(toml.loads(buf.decode("utf-8")))

    def write_chunk(self, file: BinaryIO):
        b_data = bytes(toml.dumps(self), "utf-8")
        _write_binary(file, "<IQ", int(self.chunk_identifier()), len(b_data))
        file.write(b_data)


def load_metadata(file: Union[str, bytes, int, PathLike]) -> Metadata:
    """
    Load a Metadata chunk from the given file.

    Parameters
    ----------
    file : str, bytes, int, PathLike
        Finalfusion file with a metadata chunk.

    Returns
    -------
    metadata : Metadata
        The Metadata from the file.

    Raises
    ------
    ValueError
        If the file did not contain an Metadata chunk.
    """
    with open(file, 'rb') as inf:
        chunk = find_chunk(inf, [ChunkIdentifier.Metadata])
        if chunk is None:
            raise ValueError("File did not contain a Metadata chunk")
        if chunk == ChunkIdentifier.Metadata:
            return Metadata.read_chunk(inf)
        raise ValueError(f"unexpected chunk: {str(chunk)}")


__all__ = ['Metadata', 'load_metadata']
