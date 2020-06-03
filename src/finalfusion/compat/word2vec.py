"""
Word2vec binary format.
"""

import sys
from os import PathLike
from typing import Union, BinaryIO, AnyStr

import numpy as np

from finalfusion.embeddings import Embeddings
from finalfusion.io import _serialize_array_as_le
from finalfusion.storage import NdArray
from finalfusion._util import _normalize_matrix
from finalfusion.vocab import SimpleVocab


def load_word2vec(file: Union[str, bytes, int, PathLike]) -> Embeddings:
    """
    Read embeddings in word2vec binary format.

    The returned embeddings have a SimpleVocab, NdArray storage and a Norms chunk. The storage is
    l2-normalized per default and the corresponding norms are stored in the Norms.

    Files are expected to start with a line containing rows and cols in utf-8. Words are encoded
    in utf-8 followed by a single whitespace. After the whitespace, the embedding components are
    expected as little-endian single-precision floats.

    Parameters
    ----------
    file : str, bytes, int, PathLike
        Path to a file with embeddings in word2vec binary format.

    Returns
    -------
    embeddings : Embeddings
        The embeddings from the input file.
    """
    words = []
    with open(file, 'rb') as inf:
        rows, cols = map(int, inf.readline().decode("ascii").split())
        matrix = np.zeros((rows, cols), dtype=np.float32)
        for row in matrix:
            words.append(_read_binary_word(inf, b' ').strip())
            array = np.fromfile(file=inf, count=cols, dtype=np.float32)
            if sys.byteorder == "big":
                array.byteswap(inplace=True)
            row[:] = array
    storage = NdArray(matrix)
    return Embeddings(storage=storage,
                      norms=_normalize_matrix(storage),
                      vocab=SimpleVocab(words))


def write_word2vec(file: Union[str, bytes, int, PathLike],
                   embeddings: Embeddings):
    r"""
    Write embeddings in word2vec binary format.

    If the embeddings are not compatible with the w2v format (e.g. include a SubwordVocab), only
    the known words and embeddings are serialized. I.e. the subword matrix is discarded.

    Embeddings are un-normalized before serialization, if norms are present, each embedding is
    scaled by the associated norm.

    The output file will contain the shape encoded in utf-8 on the first line as `rows columns`.
    This is followed by the embeddings.

    Each embedding consists of:

    * utf-8 encoded word
    * single space ``' '`` following the word
    * ``cols`` single-precision floating point numbers
    *  ``'\n'`` newline at the end of each line.

    Parameters
    ----------
    file : str, bytes, int, PathLike
        Output file
    embeddings : Embeddings
        The embeddings to serialize.
    """
    vocab = embeddings.vocab
    matrix = embeddings.storage[:len(vocab)]
    with open(file, 'wb') as outf:
        outf.write(f'{matrix.shape[0]} {matrix.shape[1]}\n'.encode('ascii'))
        for idx, word in enumerate(vocab):
            row = matrix[idx]  # type: np.ndarray
            if embeddings.norms is not None:
                row = row * embeddings.norms[idx]
            b_word = word.encode('utf-8')
            outf.write(b_word)
            outf.write(b' ')
            _serialize_array_as_le(outf, row)
            outf.write(b'\n')


def _read_binary_word(inf: BinaryIO, delim: AnyStr):
    word = []
    while True:
        byte = inf.read(1)
        if byte == delim:
            break
        if byte == b'':
            raise EOFError
        word.append(byte)
    return b''.join(word).decode('utf-8')


__all__ = ['load_word2vec', 'write_word2vec']
