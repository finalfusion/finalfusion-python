"""
This module defines some common IO operations and types.

:class:`Chunk` is the building block of finalfusion embeddings, each component
is serialized as its own, non-overlapping, chunk in finalfusion files.

:class:`ChunkIdentifier` is a unique integer identifiers for :class:`Chunk`.

:class:`TypeId` is used to uniquely identify numerical types.

The :class:`Header` handles the preamble of finalfusion files.

:class:`FinalfusionFormatError` is raised upon reading from malformed finalfusion
files.
"""
import struct
from abc import ABC, abstractmethod
from enum import unique, IntEnum
from typing import IO, Optional, Tuple, List

_MAGIC = b'FiFu'
VERSION = 0


class Chunk(ABC):
    """
    Basic building blocks of finalfusion files.
    """
    def write(self, path: str):
        """
        Write the Chunk as a standalone finalfusion file.

        Parameters
        ----------
        path : str
            Output path

        Raises
        ------
        TypeError
            If the Chunk is a :class:`Header`.
        """
        with open(path, "wb") as file:
            chunk_id = self.chunk_identifier()
            if chunk_id == ChunkIdentifier.Header:
                raise TypeError("Cannot write header to file by itself")
            Header([chunk_id]).write_chunk(file)
            self.write_chunk(file)

    @staticmethod
    @abstractmethod
    def chunk_identifier() -> 'ChunkIdentifier':
        """
        Get the ChunkIdentifier for this Chunk.

        Returns
        --------
        chunk_identifier : ChunkIdentifier
        """
    @staticmethod
    @abstractmethod
    def read_chunk(file: IO[bytes]) -> 'Chunk':
        """
        Read the Chunk and return it.

        The file must be positioned before the contents of the :class:`Chunk`
        but after its header.

        Parameters
        -----------
        file : IO[bytes]
            a finalfusion file containing the given Chunk

        Returns
        --------
        chunk: Chunk
            The chunk read from the file.
        """
    @abstractmethod
    def write_chunk(self, file: IO[bytes]):
        """
        Write the Chunk to a file.

        Parameters
        ----------
        file : IO[bytes]
            Output file for the Chunk
        """
    @staticmethod
    def read_chunk_header(file: IO[bytes]
                          ) -> Optional[Tuple['ChunkIdentifier', int]]:
        """
        Reads the chunk header.

        After successfully reading the header, a tuple containing
        :class:`.ChunkIdentifier` and and integer specifying the chunk size in
        bytes are returned.

        Parameters
        ----------
        file : IO[bytes]
            a finalfusion file positioned before a chunk header.

        Returns
        -------
        chunk_header : Optional[(ChunkIdentifier, int)]
            None is returned iff the reader is at EOF.

        Raises
        ------
        FinalfusionFormatError
            If only part of the header could be read.
        """
        val = Chunk._read_binary(file, "<IQ")
        if val is None:
            return None
        return ChunkIdentifier(val[0]), val[1]

    @staticmethod
    def _write_binary(file: IO[bytes], struct_fmt: str, *args):
        """
        Helper method to write binary data according to the format string.
        :param file:
        :param struct_fmt:
        :param args:
        :return:
        """
        data = struct.pack(struct_fmt, *args)
        file.write(data)

    @staticmethod
    def _read_binary(file: IO[bytes], struct_fmt: str) -> Optional[Tuple[int]]:
        """
        Helper method to read binary data from a file according to the format
        string.

        Parameters
        ----------
        file : IO[bytes]
            Output file
        struct_fmt : str
            struct format string

        Returns
        -------
        data : Optional[tuple]
            Returns the unpacked data as a tuple. If **no** data could be read,
            None is returned

        Raises
        ------
        FinalfusionFormatError
            If data could only be read partially.
        """
        size = struct.calcsize(struct_fmt)
        buf = file.read(size)
        if len(buf) == 0:
            return None
        if len(buf) != size:
            raise FinalfusionFormatError(
                f'Could not read {size} bytes from file')
        return struct.unpack(struct_fmt, buf)


class Header(Chunk):
    """
    Header Chunk

    The header chunk handles the preamble.
    """
    def __init__(self, chunk_ids):
        self.chunk_ids_ = chunk_ids

    @property
    def chunk_ids(self) -> List['ChunkIdentifier']:
        """
        Get the chunk IDs from the header

        Returns
        -------
        chunk_ids : List[ChunkIdentifier]
            List of ChunkIdentifiers in the Header.
        """
        return self.chunk_ids_

    @staticmethod
    def chunk_identifier() -> 'ChunkIdentifier':
        return ChunkIdentifier.Header

    @staticmethod
    def read_chunk(file) -> 'Header':
        magic = file.read(4)
        if magic != _MAGIC:
            invalid_magic = magic.decode('ascii', errors='ignore')
            raise FinalfusionFormatError(
                f'Magic should be b\'FiFu\', not: {invalid_magic}')
        version = Header._read_binary(file, "<I")[0]
        if version != VERSION:
            raise FinalfusionFormatError(f'Unknown model version: {version}')
        n_chunks = Header._read_binary(file, "<I")[0]
        chunk_ids = list(Header._read_binary(file, f'<{n_chunks}I'))
        return Header(chunk_ids)

    def write_chunk(self, file):
        file.write(_MAGIC)
        n_chunks = len(self.chunk_ids)
        Chunk._write_binary(file, f'<II{n_chunks}I', VERSION, n_chunks,
                            *self.chunk_ids)


def find_chunk(file: IO[bytes],
               chunks: List['ChunkIdentifier']) -> Optional['ChunkIdentifier']:
    """
    Find a :class:`Chunk` in a file.

    Looks for one of the specified `chunks` in the input file and seeks the
    file to the beginning of the first chunk found from `chunks`. I.e. the file
    is positioned before the content but after the header of a chunk.

    The :func:`Chunk.read_chunk` method can be invoked on the Chunk
    corresponding to the returned :class:`ChunkIdentifier`.

    This method seeks the input file to the beginning before searching.

    Parameters
    ----------
    file : IO[bytes]
        finalfusion file

    chunks : List[ChunkIdentifier]
        List of Chunks to look for in the input file.

    Returns
    -------
    chunk_id : Optional[ChunkIdentifier]
        The first ChunkIdentifier found in the file. None if none of the chunks
        could be found.
    """
    file.seek(0)
    Header.read_chunk(file)
    while True:
        chunk_header = Chunk.read_chunk_header(file)
        if chunk_header is None:
            return None
        chunk_id, chunk_size = chunk_header
        if chunk_id in chunks:
            return chunk_id
        file.seek(chunk_size, 1)


@unique
class ChunkIdentifier(IntEnum):
    """
    Known finalfusion Chunk types.
    """
    Header = 0
    SimpleVocab = 1
    NdArray = 2
    BucketSubwordVocab = 3
    QuantizedArray = 4
    Metadata = 5
    NdNorms = 6
    FastTextSubwordVocab = 7
    ExplicitSubwordVocab = 8


@unique
class TypeId(IntEnum):
    """
    Known finalfusion data types.
    """
    u8 = 1
    f32 = 10


class FinalfusionFormatError(Exception):
    """
    Exception to specify that the format of a finalfusion file was incorrect.
    """
