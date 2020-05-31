"""
Finalfusion Subword Vocabularies
"""

import struct
from abc import abstractmethod
from os import PathLike
from typing import List, Optional, Tuple, Any, Union, Dict, BinaryIO, cast

from finalfusion.io import ChunkIdentifier, find_chunk, _write_binary, _read_required_binary
from finalfusion.subword import ExplicitIndexer, FastTextIndexer, FinalfusionHashIndexer, ngrams
from finalfusion.vocab.vocab import Vocab, _validate_items_and_create_index, \
    _calculate_binary_list_size, _write_words_binary, _read_items, _read_items_with_indices


class SubwordVocab(Vocab):
    """
    Interface for vocabularies with subword lookups.
    """
    def idx(self, item: str, default: Optional[Union[List[int], int]] = None
            ) -> Optional[Union[List[int], int]]:
        idx = self.word_index.get(item)
        if idx is not None:
            return idx
        subwords = cast(List[int], self.subword_indices(item))
        if subwords != []:
            return subwords
        return default

    @property
    def upper_bound(self) -> int:
        return len(self) + self.subword_indexer.upper_bound

    @property
    def min_n(self) -> int:
        """
        Get the lower bound of the range of extracted n-grams.

        Returns
        -------
        min_n : int
            lower bound of n-gram range.
        """
        return self.subword_indexer.min_n

    @property
    def max_n(self) -> int:
        """
        Get the upper bound of the range of extracted n-grams.

        Returns
        -------
        max_n : int
            upper bound of n-gram range.
        """
        return self.subword_indexer.max_n

    @property
    @abstractmethod
    def subword_indexer(
            self
    ) -> Union[ExplicitIndexer, FinalfusionHashIndexer, FastTextIndexer]:
        """
        Get this vocab's subword Indexer.

        The subword indexer produces indices for n-grams.

        In case of bucket vocabularies, this is a hash-based indexer
        (:class:`.FinalfusionHashIndexer`, :class:`.FastTextIndexer`). For explicit subword
        vocabularies, this is an :class:`.ExplicitIndexer`.

        Returns
        -------
        subword_indexer : ExplicitIndexer, FinalfusionHashIndexer, FastTextIndexer
            The subword indexer of the vocabulary.
        """
    def subwords(self, item: str, bracket: bool = True) -> List[str]:
        """
        Get the n-grams of the given item as a list.

        The n-gram range is determined by the `min_n` and `max_n` values.

        Parameters
        ----------
        item : str
            The query item to extract n-grams from.
        bracket : bool
            Toggles bracketing the item with '<' and '>' before extraction.

        Returns
        -------
        ngrams : List[str]
            List of n-grams.
        """
        return ngrams(item, self.min_n, self.max_n, bracket)

    def subword_indices(self, item: str, bracket: bool = True, with_ngrams: bool = False)\
            -> List[Union[int, Tuple[str, int]]]:
        """
        Get the subword indices for the given item.

        This list does not contain the index for known items.

        Parameters
        ----------
        item : str
            The query item.
        bracket : bool
            Toggles bracketing the item with '<' and '>' before extraction.
        with_ngrams : bool
            Toggles returning ngrams together with indices.

        Returns
        -------
        indices : List[Union[int, Tuple[str, int]]]
            The list of subword indices.
        """
        return self.subword_indexer.subword_indices(item,
                                                    offset=len(self.words),
                                                    bracket=bracket,
                                                    with_ngrams=with_ngrams)

    def __getitem__(self, item: str) -> Union[int, List[int]]:
        idx = self.word_index.get(item)
        if idx is not None:
            return idx
        subwords = cast(List[int], self.subword_indices(item))
        if subwords != []:
            return subwords
        raise KeyError(f"No indices found for {item}")

    def __repr__(self) -> str:
        return f"{type(self).__name__}(\n" \
               f"\tindexer={self.subword_indexer}\n" \
               "\twords=[...]\n" \
               "\tword_index={{...}})"

    def __eq__(self, other: Any) -> bool:
        return isinstance(other, type(self)) and \
               self.subword_indexer == other.subword_indexer and \
               super(SubwordVocab, self).__eq__(other)


class FinalfusionBucketVocab(SubwordVocab):
    """
    Finalfusion Bucket Vocabulary.
    """
    def __init__(self,
                 words: List[str],
                 indexer: Optional[FinalfusionHashIndexer] = None):
        """
        Initialize a FinalfusionBucketVocab.

        Initializes the vocabulary with the given words.

        If no indexer is passed, a FinalfusionHashIndexer with bucket exponent
        21 is used.

        The word list cannot contain duplicate entries.

        Parameters
        ----------
        words : List[str]
            List of unique words
        indexer : FinalfusionHashIndexer, optional
            Subword indexer to use for the vocabulary. Defaults to an indexer
            with 2^21 buckets with range 3-6.

        Raises
        ------
        AssertionError
            If the indexer is not a FinalfusionHashIndexer or ``words`` contains duplicate entries.
        """
        if indexer is None:
            indexer = FinalfusionHashIndexer(21)
        assert isinstance(indexer, FinalfusionHashIndexer), \
            f"indexer needs to be FinalfusionHashIndexer, not {type(indexer)}"
        super().__init__()
        self._index = _validate_items_and_create_index(words)
        self._words = words
        self._indexer = indexer

    def to_explicit(self) -> 'ExplicitVocab':
        """
        Return an ExplicitVocab built from this vocab.

        This method iterates over the known words and extracts all ngrams within this vocab's
        bounds. Each of the ngrams is hashed and mapped to an index. This index is not necessarily
        unique for each ngram, if hashes collide, multiple ngrams will be mapped to the same index.

        The returned vocab will be unable to produce indices for unknown ngrams.

        The indices of the new vocabs known indices will be cover `[0, vocab.upper_bound)`

        Returns
        -------
        explicit_vocab : ExplicitVocab
            The converted vocabulary.
        """
        return _bucket_to_explicit(self)

    def write_chunk(self, file: BinaryIO):
        _write_bucket_vocab(file, self)

    @property
    def words(self) -> List[str]:
        return self._words

    @property
    def subword_indexer(self) -> FinalfusionHashIndexer:
        return self._indexer

    @property
    def word_index(self) -> Dict[str, int]:
        return self._index

    @staticmethod
    def read_chunk(file: BinaryIO) -> 'FinalfusionBucketVocab':
        length, min_n, max_n, buckets = _read_required_binary(file, "<QIII")
        words = _read_items(file, length)
        indexer = FinalfusionHashIndexer(buckets, min_n, max_n)
        return FinalfusionBucketVocab(words, indexer)

    @staticmethod
    def chunk_identifier() -> ChunkIdentifier:
        return ChunkIdentifier.BucketSubwordVocab


class FastTextVocab(SubwordVocab):
    """
    FastText vocabulary
    """
    def __init__(self,
                 words: List[str],
                 indexer: Optional[FastTextIndexer] = None):
        """
        Initialize a FastTextVocab.

        Initializes the vocabulary with the given words.

        If no indexer is passed, a FastTextIndexer with 2_000_000 buckets is used.

        The word list cannot contain duplicate entries.

        Parameters
        ----------
        words : List[str]
            List of unique words
        indexer : FastTextIndexer, optional
            Subword indexer to use for the vocabulary. Defaults to an indexer
            with 2_000_000 buckets and range 3-6.

        Raises
        ------
        AssertionError
            If the indexer is not a FastTextIndexer or ``words`` contains duplicate entries.
        """
        if indexer is None:
            indexer = FastTextIndexer(2000000)
        assert isinstance(indexer, FastTextIndexer)
        super().__init__()
        self._index = _validate_items_and_create_index(words)
        self._words = words
        self._indexer = indexer

    def to_explicit(self) -> 'ExplicitVocab':
        """
        Return an ExplicitVocab built from this vocab.

        This method iterates over the known words and extracts all ngrams within this vocab's
        bounds. Each of the ngrams is hashed and mapped to an index. This index is not necessarily
        unique for each ngram, if hashes collide, multiple ngrams will be mapped to the same index.

        The returned vocab will be unable to produce indices for unknown ngrams.

        The indices of the new vocabs known indices will be cover `[0, vocab.upper_bound)`

        Returns
        -------
        explicit_vocab : ExplicitVocab
            The converted vocabulary.
        """
        return _bucket_to_explicit(self)

    @property
    def subword_indexer(self) -> FastTextIndexer:
        return self._indexer

    @property
    def word_index(self) -> Dict[str, int]:
        return self._index

    @property
    def words(self) -> List[str]:
        return self._words

    @staticmethod
    def read_chunk(file: BinaryIO) -> 'FastTextVocab':
        length, min_n, max_n, buckets = _read_required_binary(file, "<QIII")
        words = _read_items(file, length)
        indexer = FastTextIndexer(buckets, min_n, max_n)
        return FastTextVocab(words, indexer)

    def write_chunk(self, file: BinaryIO):
        _write_bucket_vocab(file, self)

    @staticmethod
    def chunk_identifier():
        return ChunkIdentifier.FastTextSubwordVocab


class ExplicitVocab(SubwordVocab):
    """
    A vocabulary with explicitly stored n-grams.
    """
    def __init__(self, words: List[str], indexer: ExplicitIndexer):
        """
        Initialize an ExplicitVocab.

        Initializes the vocabulary with the given words and ExplicitIndexer.

        The word list cannot contain duplicate entries.

        Parameters
        ----------
        words : List[str]
            List of unique words
        indexer : ExplicitIndexer
            Subword indexer to use for the vocabulary.

        Raises
        ------
        AssertionError
            If the indexer is not an ExplicitIndexer.

        See Also
        --------
        :class:`.ExplicitIndexer`
        """
        assert isinstance(indexer, ExplicitIndexer)
        super().__init__()
        self._index = _validate_items_and_create_index(words)
        self._words = words
        self._indexer = indexer

    @property
    def word_index(self) -> Dict[str, int]:
        return self._index

    @property
    def subword_indexer(self) -> ExplicitIndexer:
        return self._indexer

    @property
    def words(self) -> List[str]:
        return self._words

    @staticmethod
    def chunk_identifier() -> ChunkIdentifier:
        return ChunkIdentifier.ExplicitSubwordVocab

    @staticmethod
    def read_chunk(file: BinaryIO) -> 'ExplicitVocab':
        length, ngram_length, min_n, max_n = _read_required_binary(
            file, "<QQII")
        words = _read_items(file, length)
        ngram_list, ngram_index = _read_items_with_indices(file, ngram_length)
        indexer = ExplicitIndexer(ngram_list, min_n, max_n, ngram_index)
        return ExplicitVocab(words, indexer)

    def write_chunk(self, file) -> None:
        chunk_length = _calculate_binary_list_size(self.words)
        chunk_length += _calculate_binary_list_size(
            self.subword_indexer.ngrams)
        min_n_max_n_size = struct.calcsize("<II")
        chunk_length += min_n_max_n_size
        chunk_header = (int(self.chunk_identifier()), chunk_length,
                        len(self.words), len(self.subword_indexer.ngrams),
                        self.min_n, self.max_n)
        _write_binary(file, "<IQQQII", *chunk_header)
        _write_words_binary((bytes(word, "utf-8") for word in self.words),
                            file)
        for ngram in self.subword_indexer.ngrams:
            b_ngram = ngram.encode("utf-8")
            _write_binary(file, "<I", len(b_ngram))
            file.write(b_ngram)
            _write_binary(file, "<Q", self.subword_indexer.ngram_index[ngram])


def load_finalfusion_bucket_vocab(file: Union[str, bytes, int, PathLike]
                                  ) -> FinalfusionBucketVocab:
    """
    Load a FinalfusionBucketVocab from the given finalfusion file.

    Parameters
    ----------
    file : str, bytes, int, PathLike
        Path to file containing a FinalfusionBucketVocab chunk.

    Returns
    -------
    vocab : FinalfusionBucketVocab
        Returns the first FinalfusionBucketVocab in the file.
    """
    with open(file, "rb") as inf:
        chunk = find_chunk(inf, [ChunkIdentifier.BucketSubwordVocab])
        if chunk is None:
            raise ValueError('File did not contain a FinalfusionBucketVocab}')
        return FinalfusionBucketVocab.read_chunk(inf)


def load_fasttext_vocab(file: Union[str, bytes, int, PathLike]
                        ) -> FastTextVocab:
    """
    Load a FastTextVocab from the given finalfusion file.

    Parameters
    ----------
    file : str, bytes, int, PathLike
        Path to file containing a FastTextVocab chunk.

    Returns
    -------
    vocab : FastTextVocab
        Returns the first FastTextVocab in the file.
    """
    with open(file, "rb") as inf:
        chunk = find_chunk(inf, [ChunkIdentifier.FastTextSubwordVocab])
        if chunk is None:
            raise ValueError('File did not contain a FastTextVocab}')
        return FastTextVocab.read_chunk(inf)


def load_explicit_vocab(file: Union[str, bytes, int, PathLike]
                        ) -> ExplicitVocab:
    """
    Load a ExplicitVocab from the given finalfusion file.

    Parameters
    ----------
    file : str, bytes, int, PathLike
        Path to file containing a ExplicitVocab chunk.

    Returns
    -------
    vocab : ExplicitVocab
        Returns the first ExplicitVocab in the file.
    """
    with open(file, "rb") as inf:
        chunk = find_chunk(inf, [ChunkIdentifier.ExplicitSubwordVocab])
        if chunk is None:
            raise ValueError('File did not contain a FastTextVocab}')
        return ExplicitVocab.read_chunk(inf)


def _bucket_to_explicit(vocab: Union[FinalfusionBucketVocab, FastTextVocab]
                        ) -> 'ExplicitVocab':
    ngram_index = dict()
    idx_index = dict()  # type: Dict[int, int]
    ngram_list = []
    for word in vocab.words:
        token_ngrams = vocab.subwords(word)
        for ngram in token_ngrams:
            if ngram not in ngram_index:
                ngram_list.append(ngram)
                idx = vocab.subword_indexer(ngram)
                if idx not in idx_index:
                    idx_index[idx] = len(idx_index)
                ngram_index[ngram] = idx_index[idx]
    indexer = ExplicitIndexer(ngram_list, vocab.min_n, vocab.max_n,
                              ngram_index)
    return ExplicitVocab(vocab.words, indexer)


def _write_bucket_vocab(file: BinaryIO,
                        vocab: Union[FastTextVocab, FinalfusionBucketVocab]):
    min_n_max_n_size = struct.calcsize("<II")
    buckets_size = struct.calcsize("<I")
    chunk_length = _calculate_binary_list_size(vocab.words)
    chunk_length += min_n_max_n_size
    chunk_length += buckets_size

    chunk_id = vocab.chunk_identifier()
    if chunk_id == ChunkIdentifier.FastTextSubwordVocab:
        buckets = vocab.subword_indexer.upper_bound
    else:
        buckets = cast(FinalfusionHashIndexer,
                       vocab.subword_indexer).buckets_exp

    chunk_header = (int(chunk_id), chunk_length, len(vocab.words), vocab.min_n,
                    vocab.max_n, buckets)
    _write_binary(file, "<IQQIII", *chunk_header)
    _write_words_binary((bytes(word, "utf-8") for word in vocab.words), file)


__all__ = [
    'SubwordVocab', 'FinalfusionBucketVocab', 'load_finalfusion_bucket_vocab',
    'FastTextVocab', 'load_fasttext_vocab', 'ExplicitVocab',
    'load_explicit_vocab'
]
