# cython: language_level=3
# cython: embedsignature=True
# cython: infer_types=True
cimport cython
from cpython cimport array
from libc.stdint cimport int8_t, uint8_t, uint32_t, uint64_t, UINT32_MAX

from .fnv cimport Fnv64_t, FNV1A_64_INIT, fnv_64a_buf, Fnv32_t, FNV1_32_INIT
from .endian cimport htole32, htole64

# subword_indices methods could be optimized by calculating the number of ngrams and preallocating an array.array:
# cdef size_t n_ngrams = <size_t> (0.5 * (-1. + min_n - max_n)*(min_n + max_n - 2. * (1. + length)) )
# cdef array.array result = array.array('Q')
# array.resize(result, n_ngrams)
# downside of this is returning an array in place of list. Speedup ~30%

cdef class FinalfusionHashIndexer:
    """
    FinalfusionHashIndexer

    FinalfusionHashIndexer is a hash-based subword indexer. It hashes n-grams with the FNV-1a
    algorithm and maps the hash to a predetermined bucket space.

    N-grams can be indexed directly through the `__call__` method or all n-grams in a string
    can be indexed in bulk through the `subword_indices` method.
    """
    cdef uint32_t _min_n
    cdef uint32_t _max_n
    cdef uint64_t _buckets_exp
    cdef uint64_t mask

    def __init__(self, bucket_exp=21, min_n=3, max_n=6):
        assert max_n >= min_n > 0, \
            f"Min_n ({min_n}) must be greater than 0, max_n ({min_n}) must be >= min_n"
        assert 0 < bucket_exp < 64, \
            f"bucket_exp ({bucket_exp}) needs to be greater than 0 and less than 64"
        self._min_n = min_n
        self._max_n = max_n
        self._buckets_exp = bucket_exp
        self.mask = ((1 << bucket_exp) - 1)

    def __call__(self, str ngram):
        return fifu_hash_ngram(ngram, 0, len(ngram)) & self.mask

    @property
    def upper_bound(self) -> int:
        """
        Get the **exclusive** upper bound

        This is the number of distinct indices.

        Returns
        -------
        upper_bound : int
            Exclusive upper bound of the indexer.
        """
        return pow(2, self._buckets_exp)

    @property
    def buckets_exp(self):
        """
        The bucket exponent.

        The indexer has 2**buckets_exp buckets.

        Returns
        -------
        buckets_exp : int
            The buckets exponent
        """
        return self._buckets_exp

    @property
    def min_n(self):
        """
        The lower bound of the n-gram range.

        Returns
        -------
        min_n : int
            Lower bound of n-gram range
        """
        return self._min_n

    @property
    def max_n(self):
        """
        The upper bound of the n-gram range.

        Returns
        -------
        max_n : int
            Upper bound of n-gram range
        """
        return self._max_n

    cpdef subword_indices(self, str word, uint64_t offset = 0, bracket=True, with_ngrams=False):
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
            raise TypeError("Can't extract ngrams for None type")
        if bracket:
            word = f"<{word}>"
        cdef uint64_t h
        cdef Py_ssize_t i, j
        cdef Py_ssize_t length = len(word)
        cdef list ngrams = []
        if length < self._min_n:
            return ngrams
        cdef uint32_t max_n = min(length, self._max_n)
        # iterate over starting points
        for i in range(length + 1 - self._min_n):
            # iterate over ngram lengths, long to short
            for j in range(max_n, self._min_n - 1, -1):
                if j + i <= length:
                    h = (fifu_hash_ngram(word, i, j) & self.mask) + offset
                    if with_ngrams:
                        ngrams.append((word[i:i + j], h))
                    else:
                        ngrams.append(h)
        return ngrams

    def __eq__(self, other):
        return isinstance(other, FinalfusionHashIndexer) and \
               self.min_n == other.min_n and \
               self.max_n == other.max_n and \
               self.buckets_exp == other.buckets_exp

    def __repr__(self):
        return f'FinalfusionHashIndexer(buckets_exp={self._buckets_exp}, min_n={self._min_n}, max_n={self._max_n})'


cdef class FastTextIndexer:
    """
    FastTextIndexer

    FastTextIndexer is a hash-based subword indexer. It hashes n-grams with (a slightly faulty)
    FNV-1a variant and maps the hash to a predetermined bucket space.

    N-grams can be indexed directly through the `__call__` method or all n-grams in a string
    can be indexed in bulk through the `subword_indices` method.
    """
    cdef uint32_t _min_n
    cdef uint32_t _max_n
    cdef uint64_t _n_buckets

    def __init__(self, n_buckets=2000000, min_n=3, max_n=6):
        assert max_n >= min_n > 0, \
            f"Min_n ({min_n}) must be greater than 0, max_n ({min_n}) must be >= min_n"
        assert 0 < n_buckets <= UINT32_MAX, \
            f"n_buckets ({n_buckets}) needs to be between 0 and {pow(2, 32)}"
        self._min_n = min_n
        self._max_n = max_n
        self._n_buckets = n_buckets

    def __call__(self, str ngram):
        cdef bytes b_ngram = ngram.encode("utf8")
        return ft_hash_ngram(b_ngram, 0, len(b_ngram)) % self._n_buckets

    @property
    def n_buckets(self):
        """
        Get the number of buckets.

        Returns
        -------
        n_buckets : int
            Number of buckets
        """
        return self._n_buckets

    @property
    def min_n(self):
        """
        The lower bound of the n-gram range.

        Returns
        -------
        min_n : int
            Lower bound of n-gram range
        """
        return self._min_n

    @property
    def max_n(self):
        """
        The upper bound of the n-gram range.

        Returns
        -------
        max_n : int
            Upper bound of n-gram range
        """
        return self._max_n

    @cython.cdivision(True)
    cpdef subword_indices(self,
                          str word,
                          uint64_t offset=0,
                          bracket=True,
                          with_ngrams=False):
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
        cdef unsigned int start, end
        cdef Py_ssize_t i, j
        cdef uint64_t h
        if bracket:
            word = "<%s>" % word
        cdef bytes b_word = word.encode("utf-8")
        cdef const uint8_t* b_word_ptr = b_word
        cdef array.array offsets = find_utf8_boundaries(b_word_ptr, len(b_word))
        cdef Py_ssize_t length = len(word)
        cdef uint32_t max_n = min(self._max_n, length)
        cdef list ngrams = []
        # iterate over starting points by character
        for i in range(length + 1 - self._min_n):
            # offsets[i] corresponds to the byte offset to the start of the char at word[i]
            start = offsets.data.as_uints[i]
            # iterate over ngram lengths, long to short
            for j in range(max_n, self._min_n - 1, -1):
                if j + i <= length:
                    # offsets[i+j] holds the exclusive upper bounds of the bytes for the character word[i+j-1]
                    end = offsets.data.as_uints[i + j]
                    h = ft_hash_ngram(b_word_ptr, start, end) % self._n_buckets + offset
                    if with_ngrams:
                        ngrams.append((word[i:i + j], h))
                    else:
                        ngrams.append(h)
        return ngrams

    @property
    def upper_bound(self) -> int:
        return self._n_buckets


    def __eq__(self, other):
        return isinstance(other, FastTextIndexer) and \
               self.min_n == other.min_n and \
               self.max_n == other.max_n and \
               self.n_buckets == other.n_buckets

    def __repr__(self):
        return f'FastTextIndexer(n_buckets={self._n_buckets}, min_n={self._min_n}, max_n={self._max_n})'


cdef array.array find_utf8_boundaries(const uint8_t* w, const Py_ssize_t n_bytes):
    cdef unsigned int b
    cdef Py_ssize_t i = 0
    cdef unsigned int mask = 0xC0
    cdef unsigned int cont = 0x80
    cdef array.array offsets = array.array('I')
    # n_bytes + 1 to store n_bytes as final boundary
    array.resize(offsets, n_bytes + 1)
    for b in range(n_bytes):
        # byte w[b] is not a continuation byte, therefore beginning of char; store offset
        if (w[b] & mask) != cont:
            offsets.data.as_uints[i] = b
            i += 1
    offsets.data.as_uints[i] = <unsigned int> n_bytes
    return offsets

cdef uint32_t PRIME32 = 16777619

cdef uint64_t fifu_hash_ngram(str word, const Py_ssize_t start, const Py_ssize_t length):
    cdef Py_ssize_t i = 0
    cdef Fnv64_t h = FNV1A_64_INIT
    cdef uint32_t c
    cdef uint64_t u_length = htole64(length)
    h = fnv_64a_buf(<uint8_t*> &u_length, 8, h)
    for i in range(start, start + length):
        # extract unicode for char, cast to u8 pointer for hashing.
        # extracting bytes manually from memoryview/bytes is
        # more complex because of handling prefixes.
        c = htole32(ord(word[i]))
        h = fnv_64a_buf(&c, 4, h)
    return h

cdef uint64_t ft_hash_ngram(const uint8_t* b_word, const Py_ssize_t start, const Py_ssize_t end):
    cdef Py_ssize_t i
    cdef Fnv32_t h = FNV1_32_INIT
    # iterate over bytes in range start..end and hash each byte
    for i in range(start, end):
        h ^= <uint32_t> (<int8_t> b_word[i])
        h *= PRIME32
    return h

__all__ = ['FinalfusionHashIndexer', 'FastTextIndexer']