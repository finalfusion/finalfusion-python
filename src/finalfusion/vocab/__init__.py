"""
Finalfusion Vocabularies
"""

from finalfusion.io import ChunkIdentifier, find_chunk
from finalfusion.vocab.simple_vocab import SimpleVocab, load_simple_vocab
from finalfusion.vocab.vocab import Vocab


def load_vocab(path: str) -> Vocab:
    """
    Load any vocabulary from a finalfusion file.

    Loads the first known vocabulary from a finalfusion file.

    Parameters
    ----------
    path : str
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
    with open(path, "rb") as file:
        chunk = find_chunk(file, [
            ChunkIdentifier.SimpleVocab, ChunkIdentifier.FastTextSubwordVocab,
            ChunkIdentifier.ExplicitSubwordVocab,
            ChunkIdentifier.BucketSubwordVocab
        ])
        if chunk is None:
            raise ValueError('File did not contain a vocabulary')
        if chunk == ChunkIdentifier.SimpleVocab:
            return SimpleVocab.read_chunk(file)
        raise NotImplementedError('Vocab type is not yet supported.')
