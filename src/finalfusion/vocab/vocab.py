"""
Finalfusion Vocabulary interface
"""
import abc
import struct
from typing import List, Optional, Dict, Tuple, BinaryIO, Iterable, Any, Union, Sequence, \
    Iterator, Collection

from finalfusion.io import Chunk, _read_required_binary, _write_binary


class Vocab(Chunk, Collection[str]):
    """
    Finalfusion vocabulary interface.

    Vocabs provide at least a simple string to index mapping and index to
    string mapping. Vocab is the base type of all vocabulary types.
    """
    @property
    @abc.abstractmethod
    def words(self) -> List[str]:
        """
        Get the list of known words

        Returns
        -------
        words : List[str]
            list of known words
        """
    @property
    @abc.abstractmethod
    def word_index(self) -> Dict[str, int]:
        """
        Get the index of known words

        Returns
        -------
        dict : Dict[str, int]
            index of known words
        """
    @property
    @abc.abstractmethod
    def upper_bound(self) -> int:
        """
        The exclusive upper bound of indices in this vocabulary.

        Returns
        -------
        upper_bound : int
           Exclusive upper bound of indices covered by the vocabulary.
        """
    @abc.abstractmethod
    def idx(self, item: str, default: Optional[Union[int, List[int]]] = None
            ) -> Optional[Union[int, List[int]]]:
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
    def __getitem__(self, item: str) -> Union[int, List[int]]:
        return self.word_index[item]

    def __contains__(self, item: Any) -> bool:
        # usual case: checking whether a str is known
        if isinstance(item, str):
            return self.word_index.get(item) is not None
        # e.g. allows checking whether one vocab is the superset of another
        if hasattr(item, "__iter__"):
            return all(w in self for w in item)
        return False

    def __iter__(self) -> Iterator[str]:
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


def _write_words_binary(b_words: Iterable[bytes], file: BinaryIO):
    """
    Helper method to write an iterable of bytes and their lengths.
    """
    for word in b_words:
        _write_binary(file, "<I", len(word))
        file.write(word)


def _read_items(file: BinaryIO, length: int) -> List[str]:
    """
    Helper method to read items from a vocabulary chunk.

    Parameters
    ----------
    file : BinaryIO
        input file
    length : int
        number of items to read

    Returns
    -------
    words : List[str]
        The word list
    """
    items = []
    for _ in range(length):
        item_length = _read_required_binary(file, "<I")[0]
        word = file.read(item_length).decode("utf-8")
        items.append(word)
    return items


def _read_items_with_indices(file: BinaryIO,
                             length: int) -> Tuple[List[str], Dict[str, int]]:
    """
    Helper method to read items from a vocabulary chunk.

    Parameters
    ----------
    file : BinaryIO
        input file
    length : int
        number of items to read

    Returns
    -------
    words : List[str]
        The word list
    """
    items = []
    index = dict()
    for _ in range(length):
        item_length = _read_required_binary(file, "<I")[0]
        item = file.read(item_length).decode("utf-8")
        idx = _read_required_binary(file, "<Q")[0]
        items.append(item)
        index[item] = idx
    return items, index


def _calculate_binary_list_size(items: List[str]):
    size = sum(len(bytes(item, "utf-8")) for item in items)
    size += struct.calcsize("<Q")
    size += len(items) * struct.calcsize("<I")
    return size


def _validate_items_and_create_index(items: Sequence[str]) -> Dict[str, int]:
    index = dict((item, idx) for idx, item in enumerate(items))
    n_unique_items = len(index)
    assert len(items) == n_unique_items,\
        f"Vocab items cannot be duplicated. List: {len(items)}, Unique: {n_unique_items}"
    assert len(index) == len(items),\
        f"Items and index need to have same length ({len(items)}, {len(index)})"
    return index


__all__ = ['Vocab']
