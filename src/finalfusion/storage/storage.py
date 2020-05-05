"""
Storage
"""

import abc
from typing import Tuple, IO

from finalfusion.io import Chunk


class Storage(Chunk):
    """
    Common interface to finalfusion storage types.
    """
    @property
    @abc.abstractmethod
    def shape(self) -> Tuple[int, int]:
        """
        Get the shape of the storage.

        Returns
        -------
        shape : Tuple[int, int]
            Tuple containing `(rows, columns)`
        """
    @abc.abstractmethod
    def __getitem__(self, index):
        pass

    @classmethod
    def load(cls, file: IO[bytes], mmap: bool = False) -> 'Storage':
        """
        Load Storage from the given finalfusion file.

        Parameters
        ----------
        file : IO[bytes]
            Finalfusion file with a storage chunk
        mmap : bool

        Returns
        -------
        storage : Storage
            The first storage in the input file
        mmap : bool
            Toggles memory mapping the storage buffer as read-only.

        Raises
        ------
        ValueError
            If the file did not contain a storage.
        """
        return cls.mmap_chunk(file) if mmap else cls.read_chunk(file)

    @staticmethod
    @abc.abstractmethod
    def mmap_chunk(file: IO[bytes]) -> 'Storage':
        """
        Memory maps the storage as a read-only buffer.

        Parameters
        ----------
        file : IO[bytes]
            Finalfusion file with a storage chunk

        Returns
        -------
        storage : Storage
            The first storage in the input file

        Raises
        ------
        ValueError
            If the file did not contain a storage.
        """
