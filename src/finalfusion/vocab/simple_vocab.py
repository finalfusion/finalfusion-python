"""
Finalfusion SimpleVocab
"""
import struct
from os import PathLike
from typing import List, Optional, Union, BinaryIO, Dict

from finalfusion.io import ChunkIdentifier, find_chunk, _write_binary, _read_required_binary
from finalfusion.vocab.vocab import Vocab, _validate_items_and_create_index, _read_items,\
    _write_words_binary


class SimpleVocab(Vocab):
    """
    Simple vocabulary.

    SimpleVocabs provide a simple string to index mapping and index to string
    mapping.
    """
    def __init__(self, words: List[str]):
        """
        Initialize a SimpleVocab.

        Initializes the vocabulary with the given words and optional index. If
        no index is given, the nth word in the `words` list is assigned index
        `n`. The word list cannot contain duplicate entries and it needs to be
        of same length as the index.

        Parameters
        ----------
        words : List[str]
            List of unique words

        Raises
        ------
        AssertionError
            if ``words`` contains duplicate entries.
        """
        self._index = _validate_items_and_create_index(words)
        self._words = words

    @property
    def words(self) -> List[str]:
        return self._words

    @property
    def word_index(self) -> Dict[str, int]:
        return self._index

    @property
    def upper_bound(self) -> int:
        return len(self.word_index)

    def idx(self, item: str, default: Union[list, int, None] = None
            ) -> Optional[Union[list, int]]:
        return self.word_index.get(item, default)

    @staticmethod
    def read_chunk(file: BinaryIO) -> 'SimpleVocab':
        length = _read_required_binary(file, "<Q")[0]
        words = _read_items(file, length)
        return SimpleVocab(words)

    def write_chunk(self, file: BinaryIO):
        _write_binary(file, "<I", int(self.chunk_identifier()))
        b_word_len_sum = sum(len(bytes(word, "utf-8")) for word in self.words)
        n_words_size = struct.calcsize("<Q")
        word_lens_size = len(self.words) * struct.calcsize("<I")
        chunk_length = n_words_size + word_lens_size + b_word_len_sum
        _write_binary(file, "<QQ", chunk_length, len(self.words))
        _write_words_binary((bytes(word, "utf-8") for word in self.words),
                            file)

    @staticmethod
    def chunk_identifier() -> ChunkIdentifier:
        return ChunkIdentifier.SimpleVocab


def load_simple_vocab(file: Union[str, bytes, int, PathLike]) -> SimpleVocab:
    """
    Load a SimpleVocab from the given finalfusion file.

    Parameters
    ----------
    file : str
        Path to file containing a SimpleVocab chunk.

    Returns
    -------
    vocab : SimpleVocab
        Returns the first SimpleVocab in the file.
    """
    with open(file, "rb") as inf:
        chunk = find_chunk(inf, [ChunkIdentifier.SimpleVocab])
        if chunk is None:
            raise ValueError('File did not contain a SimpleVocab}')
        return SimpleVocab.read_chunk(inf)


__all__ = ['SimpleVocab', 'load_simple_vocab']
