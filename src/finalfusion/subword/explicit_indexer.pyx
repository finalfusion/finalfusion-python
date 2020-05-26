# cython: language_level=3
# cython: embedsignature=True
# cython: infer_types=True

from typing import List, Optional, Dict, Iterable

from libc.stdint cimport uint32_t, uint64_t

cdef class ExplicitIndexer:
    """
    ExplicitIndexer

    Explicit Indexers do not index n-grams through hashing but define an actual lookup table.

    It can be constructed from a list of **unique** ngrams. In that case, the ith ngram in the
    list will be mapped to index i. It is also possible to pass a mapping via `ngram_index`
    which allows mapping multiple ngrams to the same value.

    N-grams can be indexed directly through the `__call__` method or all n-grams in a string
    can be indexed in bulk through the `subword_indices` method.

    `subword_indices` optionally returns tuples of form `(ngram, idx)`, otherwise a list of
    indices belonging to the input string is returned.
    """
    cdef dict _ngram_index
    cdef list _ngrams
    cdef Py_ssize_t _bound
    cdef uint32_t _min_n
    cdef uint32_t _max_n

    def __init__(self,
                 ngrams: List[str],
                 min_n: int = 3,
                 max_n: int = 6,
                 ngram_index: Optional[Dict[str, int]] = None):
        self._ngrams = ngrams
        assert max_n >= min_n > 0, \
            f"Min_n ({min_n}) must be greater than 0, max_n ({max_n}) must be >= min_n"
        self._min_n = min_n
        self._max_n = max_n
        if ngram_index is None:
            ngram_index = dict(
                (ngram, idx) for idx, ngram in enumerate(ngrams))
            assert len(ngrams) == len(ngram_index), \
                f'ngrams cannot contain duplicate entries. {len(ngrams) - len(ngram_index)} duplicates.'
            self._bound = len(ngram_index)
        else:
            unique_ngrams = set(ngrams)
            n_unique_ngrams = len(unique_ngrams)
            assert n_unique_ngrams == len(ngrams), \
                f'ngrams cannot contain duplicate entries. {len(ngrams) - n_unique_ngrams} duplicates.'
            assert all(ngram in ngram_index for ngram in unique_ngrams) and (len(ngram_index) == len(ngrams)), \
                'ngram_index needs to index all and only items in the ngrams list.'
            max_idx = max(ngram_index.values())
            n_unique_vals = len(set(ngram_index.values()))
            assert max_idx + 1 == n_unique_vals, \
                f"Indices need to cover 0, max(ngram_index.values())"
            self._bound = max_idx + 1
        self._ngram_index = ngram_index

    @property
    def ngrams(self) -> List[str]:
        """
        Get the list of n-grams.

        **Note:** If you mutate this list you can make the indexer invalid.

        Returns
        -------
        ngrams : List[str]
            The list of in-vocabulary n-grams.
        """
        return self._ngrams

    @property
    def ngram_index(self) -> Dict[str, int]:
        """
        Get the ngram-index mapping.

        **Note:** If you mutate this mapping you can make the indexer invalid.

        Returns
        -------
        ngram_index : Dict[str, int]
            The ngram -> index mapping.
        """
        return self._ngram_index

    @property
    def min_n(self) -> int:
        """
        The lower bound of the n-gram range.

        Returns
        -------
        min_n : int
            Lower bound of n-gram range
        """
        return self._min_n

    @property
    def max_n(self) -> int:
        """
        The upper bound of the n-gram range.

        Returns
        -------
        max_n : int
            Upper bound of n-gram range
        """
        return self._max_n

    @property
    def upper_bound(self) -> int:
        """
        Get the **exclusive** upper bound

        This is the number of distinct indices.

        This number can become invalid if `ngram_index` or `ngrams` is mutated.

        Returns
        -------
        idx_bound : int
            Exclusive upper bound of the indexer.
        """
        return self._bound

    cpdef subword_indices(self, str word, uint64_t offset=0, bracket=True, with_ngrams=False):
        """
        Get the subword indices for a word.
        
        Parameters
        ----------
        word : str
            The string to extract n-grams from
        offset : int
            The offset to add to the index, e.g. the length of the word-vocabulary.
        bracket : bool
            Toggles bracketing the input string with `<` and `>`
        with_ngrams : bool
            Toggles returning tuples of (ngram, idx)
        
        Returns
        -------
        indices : list
            List of n-gram indices, optionally as `(str, int)` tuples.
        
        Raises
        ------
        TypeError
            If `word` is None.
        """
        if word is None:
            raise TypeError("Can't extract ngrams for None")
        if bracket:
            word = "<%s>" % word
        cdef Py_ssize_t i, j
        cdef Py_ssize_t length = len(word)
        cdef list ngrams = []
        if length < self._min_n:
            return ngrams
        cdef Py_ssize_t max_n = min(self._max_n, length)
        for i in range(length + 1 - self._min_n):
            for j in range(max_n, self._min_n - 1, -1):
                if j + i <= length:
                    ngram = word[i:i + j]
                    idx = self._ngram_index.get(ngram)
                    if idx is None:
                        continue
                    if with_ngrams:
                        ngrams.append((ngram, idx + offset))
                    else:
                        ngrams.append(idx + offset)
        return ngrams

    def __getitem__(self, ngram: str) -> int:
        return self.ngram_index[ngram]

    def __call__(self, ngram: str) -> Optional[int]:
        return self.ngram_index.get(ngram)

    def __iter__(self) -> Iterable[str]:
        return iter(self._ngrams)

    def __len__(self) -> int:
        return len(self._ngram_index)

    def __eq__(self, other) -> bool:
        if not isinstance(other, ExplicitIndexer):
            return False
        return (self.upper_bound == other.upper_bound) and \
               (self.max_n == other.max_n) and \
               (self.min_n == other.min_n) and \
               (self.ngrams == other.ngrams) and \
               (self.ngram_index == other.ngram_index)

    def __contains__(self, item) -> bool:
        if isinstance(item, str):
            return item in self.ngram_index
        if hasattr(item, "__iter__"):
            return all(w in self for w in item)
        return False

    def __repr__(self) -> str:
        return "ExplicitIndexer(\n" \
               f"\tmin_n={self.min_n},\n" \
               f"\tmax_n={self.max_n},\n" \
               "\tngrams=[...],\n" \
               "\tngram_index={{...}})"

__all__ = ['ExplicitIndexer']
