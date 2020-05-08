"""
Finalfusion Vocabularies
"""
from os import PathLike
from typing import Union

from finalfusion.io import ChunkIdentifier, find_chunk
from finalfusion.vocab.simple_vocab import SimpleVocab, load_simple_vocab
from finalfusion.vocab.vocab import Vocab


def load_vocab(file: Union[str, bytes, int, PathLike]) -> Vocab:
    """
    Load any vocabulary from a finalfusion file.

    Loads the first known vocabulary from a finalfusion file.

    Parameters
    ----------
    file: str, bytes, int, PathLike
        Path to file containing a finalfusion vocab chunk.

    Returns
    -------
    vocab : Union[SimpleVocab]
        First vocabulary in the file.

    Raises
    ------
    ValueError
         If the file did not contain a vocabulary.
    """
    with open(file, "rb") as inf:
        chunk = find_chunk(inf, [
            ChunkIdentifier.SimpleVocab, ChunkIdentifier.FastTextSubwordVocab,
            ChunkIdentifier.ExplicitSubwordVocab,
            ChunkIdentifier.BucketSubwordVocab
        ])
        if chunk is None:
            raise ValueError('File did not contain a vocabulary')
        if chunk == ChunkIdentifier.SimpleVocab:
            return SimpleVocab.read_chunk(inf)
        raise NotImplementedError('Vocab type is not yet supported.')
