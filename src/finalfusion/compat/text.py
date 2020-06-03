"""
Text based embedding formats.
"""

import re
from os import PathLike
from typing import Union, TextIO

import numpy as np

from finalfusion.embeddings import Embeddings
from finalfusion._util import _normalize_matrix
from finalfusion.storage import NdArray
from finalfusion.vocab import SimpleVocab

_ASCII_WHITESPACE_PAT = re.compile(r'(?a)\s+')


def load_text_dims(file: Union[str, bytes, int, PathLike]) -> Embeddings:
    """
    Read emebddings in text-dims format.

    The returned embeddings have a SimpleVocab, NdArray storage and a Norms chunk. The storage is
    l2-normalized per default and the corresponding norms are stored in the Norms.

    The first line contains whitespace separated rows and cols, the rest of the file contains
    whitespace separated word and vector components.

    Parameters
    ----------
    file : str, bytes, int, PathLike
        Path to a file with embeddings in word2vec binary format.
    Returns
    -------
    embeddings : Embeddings
        The embeddings from the input file.
    """
    with open(file) as inf:
        rows, cols = next(inf).split()
        return _load_text(inf, int(rows), int(cols))


def load_text(file: Union[str, bytes, int, PathLike]) -> Embeddings:
    """
    Read embeddings in text format.

    The returned embeddings have a SimpleVocab, NdArray storage and a Norms chunk. The storage is
    l2-normalized per default and the corresponding norms are stored in the Norms.

    Expects a file with utf-8 encoded lines with:

    * word at the start of the line
    * followed by whitespace
    * followed by whitespace separated vector components

    Parameters
    ----------
    file : str, bytes, int, PathLike
        Path to a file with embeddings in word2vec binary format.

    Returns
    -------
    embeddings : Embeddings
        Embeddings from the input file. The resulting Embeddings will have a
        SimpleVocab, NdArray and Norms.
    """
    with open(file) as inf:
        try:
            first = next(inf)
        except StopIteration:
            raise ValueError("Can't read from empty embeddings file.")
        line = _ASCII_WHITESPACE_PAT.split(first.rstrip())
        cols = len(line[1:])
        rows = sum(1 for _ in inf) + 1
        inf.seek(0)
        return _load_text(inf, rows, cols)


def write_text(file: Union[str, bytes, int, PathLike],
               embeddings: Embeddings,
               sep=" "):
    """
    Write embeddings in text format.

    Embeddings are un-normalized before serialization, if norms are present, each embedding is
    scaled by the associated norm.

    The output consists of utf-8 encoded lines with:
        * word at the start of the line
        * followed by whitespace
        * followed by whitespace separated vector components

    Parameters
    ----------
    file : str, bytes, int, PathLike
        Output file
    embeddings : Embeddings
        Embeddings to write
    sep : str
        Separator of word and embeddings.
    """
    _write_text(file, embeddings, False, sep=sep)


def write_text_dims(file: Union[str, bytes, int, PathLike],
                    embeddings: Embeddings,
                    sep=" "):
    """
    Write embeddings in text-dims format.

    Embeddings are un-normalized before serialization, if norms are present, each embedding is
    scaled by the associated norm.

    The output consists of utf-8 encoded lines with:
        * `rows cols` on the **first** line
        * word at the start of the line
        * followed by whitespace
        * followed by whitespace separated vector components

    Parameters
    ----------
    file : str, bytes, int, PathLike
        Output file
    embeddings : Embeddings
        Embeddings to write
    sep : str
        Separator of word and embeddings.
    """
    _write_text(file, embeddings, True, sep=sep)


def _load_text(file: TextIO, rows: int, cols: int) -> Embeddings:
    words = []
    matrix = np.zeros((rows, cols), dtype=np.float32)
    for row, line in zip(matrix, file):
        parts = _ASCII_WHITESPACE_PAT.split(line.rstrip())
        words.append(parts[0])
        row[:] = parts[1:]
    storage = NdArray(matrix)
    return Embeddings(storage=storage,
                      norms=_normalize_matrix(storage),
                      vocab=SimpleVocab(words))


def _write_text(file: Union[str, bytes, int, PathLike],
                embeddings: Embeddings,
                dims: bool,
                sep=" "):
    vocab = embeddings.vocab
    matrix = embeddings.storage[:len(vocab)]
    with open(file, 'w') as outf:
        if dims:
            print(*matrix.shape, file=outf)
        for idx, word in enumerate(vocab):
            row = matrix[idx]  # type: np.ndarray
            if embeddings.norms is not None:
                row = row * embeddings.norms[idx]
            print(word, ' '.join(map(str, row)), sep=sep, file=outf)


__all__ = ['load_text', 'load_text_dims', 'write_text', 'write_text_dims']
