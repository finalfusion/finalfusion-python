# cython: language_level=3
# cython: embedsignature=True
# cython: infer_types=True

from libc.stdint cimport uint32_t

cpdef ngrams(str word, uint32_t min_n=3, uint32_t max_n=6, bracket=True):
    """
    Get the ngrams for the given word.
    
    Parameters
    ----------
    word : str
        The string to extract n-grams from
    min_n : int
        Inclusive lower bound of n-gram range. Must be greater than zero and smaller or equal to 
        `max_n`
    max_n : int
        Inclusive upper bound of n-gram range. Must be greater than zero and greater or equal to
        `min_n`
    bracket : bool
        Toggles bracketing the input string with `<` and `>`
    
    Returns
    -------
    ngrams : list
        List of n-grams.
    
    Raises
    ------
    AssertionError
        If `max_n < min_n` or `min_n <= 0`.
    TypeError
        If `word` is None.
    """
    if word is None:
        raise TypeError("Can't extract ngrams for None")
    assert max_n >= min_n > 0
    if bracket:
        word = "<%s>" % word
    cdef Py_ssize_t i = 0
    cdef Py_ssize_t j
    cdef Py_ssize_t length = len(word)
    cdef list ngrams = []
    if length < min_n:
        return ngrams
    max_n = min(max_n, length)
    for i in range(length + 1 - min_n):
        for j in range(max_n, min_n-1, -1):
            if j + i <= length:
                ngrams.append(word[i:i + j])
    return ngrams

__all__ = ['ngrams']
