"""
Finalfusion Vocabulary interface
"""
import abc
from typing import List, Optional, Dict, Tuple, BinaryIO, Iterable, Any, Union

from finalfusion.io import Chunk, _read_binary, _write_binary


class Vocab(Chunk):
    """
    Finalfusion vocabulary interface.

    Vocabs provide at least a simple string to index mapping and index to
    string mapping. Vocab is the base type of all vocabulary types.
    """
    @property
    @abc.abstractmethod
    def words(self) -> list:
        """
        Get the list of known words

        Returns
        -------
        words : List[str]
            list of known words
        """
    @property
    @abc.abstractmethod
    def word_index(self) -> dict:
        """
        Get the index of known words

        Returns
        -------
        dict : Dict[str, int]
            index of known words
        """
    @property
    @abc.abstractmethod
    def idx_bound(self) -> int:
        """
        The exclusive upper bound of indices in this vocabulary.

        Returns
        -------
        idx_bound : int
           Exclusive upper bound of indices covered by the vocabulary.
        """
    @abc.abstractmethod
    def idx(self, item: str, default: Union[list, int, None] = None
            ) -> Optional[Union[list, int]]:
        """
        Lookup the given query item.

        This lookup does not raise an exception if the vocab can't produce indices.

        Parameters
        ----------
        item : str
            The query item.
        default : Optional[Union[int, List[int]]]
            Fall-back value to return if the vocab can't provide indices.

        Returns
        -------
        index : Optional[Union[int, List[int]]]
            * An integer if there is a single index for a known item.
            * A list if the vocab can provide subword indices for a unknown item.
            * The provided `default` item if the vocab can't provide indices.
        """
    def __getitem__(self, item: str) -> Union[list, int]:
        return self.word_index[item]

    def __contains__(self, item: Any) -> bool:
        # usual case: checking whether a str is known
        if isinstance(item, str):
            return self.word_index.get(item) is not None
        # e.g. allows checking whether one vocab is the superset of another
        if hasattr(item, "__iter__"):
            return all(w in self for w in item)
        return False

    def __iter__(self) -> Iterable[str]:
        return iter(self.words)

    def __len__(self) -> int:
        return len(self.word_index)

    def __eq__(self, other: Any) -> bool:
        if not isinstance(other, type(self)):
            return False
        if self.words != other.words:
            return False
        if self.word_index != other.word_index:
            return False
        return True

    @staticmethod
    def _write_words_binary(b_words: Iterable[bytes], file: BinaryIO):
        """
        Helper method to write an iterable of bytes and their lengths.
        """
        for word in b_words:
            _write_binary(file, "<I", len(word))
            file.write(word)

    @staticmethod
    def _read_items(file: BinaryIO, length: int,
                    indices=False) -> Tuple[List[str], Dict[str, int]]:
        """
        Helper method to read items from a vocabulary chunk.

        Parameters
        ----------
        file : BinaryIO
            input file
        length : int
            number of items to read
        indices : bool
            Toggles reading an int after each item specifying its index.

        Returns
        -------
        (words, word_index) : (List[str], Dict[str, int])
            Tuple containing the word list and the word index.
        """
        items = []
        index = {}
        for _ in range(length):
            item_length = _read_binary(file, "<I")[0]
            word = file.read(item_length).decode("utf-8")
            items.append(word)
            if indices:
                index[word] = _read_binary(file, "<Q")[0]
            else:
                index[word] = len(index)
        return items, index
