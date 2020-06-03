"""
Finalfusion Vocabularies
"""
from os import PathLike
from typing import Union

from finalfusion.io import ChunkIdentifier, find_chunk
from finalfusion.vocab.simple_vocab import SimpleVocab, load_simple_vocab
from finalfusion.vocab.subword import FinalfusionBucketVocab, load_finalfusion_bucket_vocab, \
    FastTextVocab, load_fasttext_vocab, ExplicitVocab, load_explicit_vocab, SubwordVocab
from finalfusion.vocab.vocab import Vocab


def load_vocab(file: Union[str, bytes, int, PathLike]) -> Vocab:
    """
    Load any vocabulary from a finalfusion file.

    Loads the first known vocabulary from a finalfusion file.

    One of:
        * :class:`~finalfusion.vocab.simple_vocab.SimpleVocab`,
        * :class:`~finalfusion.vocab.subword.FinalfusionBucketVocab`
        * :class:`~finalfusion.vocab.subword.FastTextVocab`
        * :class:`~finalfusion.vocab.subword.ExplicitVocab`

    Parameters
    ----------
    file: str, bytes, int, PathLike
        Path to file containing a finalfusion vocab chunk.

    Returns
    -------
    vocab : Vocab
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
        if chunk == ChunkIdentifier.BucketSubwordVocab:
            return FinalfusionBucketVocab.read_chunk(inf)
        if chunk == ChunkIdentifier.FastTextSubwordVocab:
            return FastTextVocab.read_chunk(inf)
        if chunk == ChunkIdentifier.ExplicitSubwordVocab:
            return ExplicitVocab.read_chunk(inf)
        raise ValueError(f'Unexpected chunk type {chunk}.')


__all__ = [
    'Vocab', 'load_vocab', 'SimpleVocab', 'load_simple_vocab',
    'FinalfusionBucketVocab', 'load_finalfusion_bucket_vocab', 'FastTextVocab',
    'load_fasttext_vocab', 'ExplicitVocab', 'load_explicit_vocab',
    'SubwordVocab'
]
