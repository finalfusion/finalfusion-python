"""
Finalfusion SimpleVocab
"""
import struct
from typing import List, Optional, Dict, Union

from finalfusion.io import ChunkIdentifier, find_chunk
from finalfusion.vocab.vocab import Vocab


class SimpleVocab(Vocab):
    """
    Simple vocabulary.

    SimpleVocabs provide a simple string to index mapping and index to string
    mapping. SimpleVocab is also the base type of other vocabulary types.
    """
    def __init__(self,
                 words: List[str],
                 index: Optional[Dict[str, int]] = None):
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
        index : Optional[Dict[str, int]]
            Dictionary providing an entry -> index mapping.

        Raises
        ------
        ValueError
            if the length of `index` and `word` doesn't match.
        """
        if index is None:
            index = dict((word, idx) for idx, word in enumerate(words))
        if len(index) != len(words):
            raise ValueError("Words and index need to have same length")
        self._index = index
        self._words = words

    @property
    def words(self) -> list:
        return self._words

    @property
    def word_index(self) -> dict:
        return self._index

    @property
    def idx_bound(self) -> int:
        return len(self.word_index)

    def idx(self, item: str, default: Union[list, int, None] = None
            ) -> Optional[Union[list, int]]:
        return self.word_index.get(item, default)

    @staticmethod
    def read_chunk(file) -> 'SimpleVocab':
        length = SimpleVocab._read_binary(file, "<Q")[0]
        words, index = SimpleVocab._read_items(file, length)
        return SimpleVocab(words, index)

    def write_chunk(self, file):
        SimpleVocab._write_binary(file, "<I", int(self.chunk_identifier()))
        b_word_len_sum = sum(len(bytes(word, "utf-8")) for word in self.words)
        n_words_size = struct.calcsize("<Q")
        word_lens_size = len(self.words) * struct.calcsize("<I")
        chunk_length = n_words_size + word_lens_size + b_word_len_sum
        SimpleVocab._write_binary(file, "<QQ", chunk_length, len(self.words))
        self._write_words_binary((bytes(word, "utf-8") for word in self.words),
                                 file)

    @staticmethod
    def chunk_identifier() -> ChunkIdentifier:
        return ChunkIdentifier.SimpleVocab


def load_simple_vocab(path: str) -> SimpleVocab:
    """
    Load a SimpleVocab from the given finalfusion file.

    Parameters
    ----------
    path : str
        Path to file containing a SimpleVocab chunk.

    Returns
    -------
    vocab : SimpleVocab
        Returns the first SimpleVocab in the file.
    """
    with open(path, "rb") as file:
        chunk = find_chunk(file, [ChunkIdentifier.SimpleVocab])
        if chunk is None:
            raise ValueError('File did not contain a SimpleVocab}')
        return SimpleVocab.read_chunk(file)
