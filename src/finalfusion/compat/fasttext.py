"""
Fasttext IO compat module.
"""

import sys
from os import PathLike
from typing import Union, BinaryIO, cast, List, Any, Dict

import numpy as np

from finalfusion._util import _normalize_matrix
from finalfusion.embeddings import Embeddings
from finalfusion.io import _read_required_binary, _write_binary, _serialize_array_as_le
from finalfusion.metadata import Metadata
from finalfusion.storage import NdArray
from finalfusion.subword import FastTextIndexer
from finalfusion.vocab import FastTextVocab, Vocab, SimpleVocab

_FT_MAGIC = 793_712_314


def load_fasttext(file: Union[str, bytes, int, PathLike]) -> Embeddings:
    """
    Read embeddings from a file in fastText format.

    The returned embeddings have a FastTextVocab, NdArray storage and a Norms chunk.

    Loading embeddings with this method will precompute embeddings for each word by averaging all
    of its subword embeddings together with the distinct word vector. Additionally, all precomputed
    vectors are l2-normalized and the corresponding norms are stored in the Norms. The subword
    embeddings are **not** l2-normalized.

    Parameters
    ----------
    file : str, bytes, int, PathLike
        Path to a file with embeddings in word2vec binary format.

    Returns
    -------
    embeddings : Embeddings
        The embeddings from the input file.
    """
    with open(file, 'rb') as inf:
        _read_ft_header(inf)
        metadata = _read_ft_cfg(inf)
        vocab = _read_ft_vocab(inf, metadata['buckets'], metadata['min_n'],
                               metadata['max_n'])
        storage = _read_ft_storage(inf, vocab)
        norms = _normalize_matrix(storage[:len(vocab)])
    return Embeddings(storage=storage,
                      vocab=vocab,
                      norms=norms,
                      metadata=metadata)


def write_fasttext(file: Union[str, bytes, int, PathLike], embeds: Embeddings):
    """
    Write embeddings in fastText format.

    fastText requires Metadata with all expected keys for fastText configs:
        * dims: int (inferred from model)
        * window_size: int (default -1)
        * min_count: int (default -1)
        * ns: int (default -1)
        * word_ngrams: int (default 1)
        * loss: one of ``['HierarchicalSoftmax', 'NegativeSampling', 'Softmax']`` (default Softmax)
        * model: one of ``['CBOW', 'SkipGram', 'Supervised']`` (default SkipGram)
        * buckets: int (inferred from model)
        * min_n: int (inferred from model)
        * max_n: int (inferred from model)
        * lr_update_rate: int (default -1)
        * sampling_threshold: float (default -1)

    ``dims``, ``buckets``, ``min_n`` and ``max_n`` are inferred from the model. If other values
    are unspecified, a default value of ``-1`` is used for all numerical fields. Loss defaults
    to ``Softmax``, model to ``SkipGram``. Unknown values for ``loss`` and ``model`` are
    overwritten with defaults since the models are incompatible with fastText otherwise.

    Some information from original fastText models gets lost e.g.:
        * word frequencies
        * n_tokens

    Embeddings are un-normalized before serialization: if norms are present, each embedding is
    scaled by the associated norm. Additionally, the original state of the embedding matrix is
    restored, precomputation and l2-normalization of word embeddings is undone.

    Only embeddings with a FastTextVocab or SimpleVocab can be serialized to this format.

    Parameters
    ----------
    file : str, bytes, int, PathLike
        Output file
    embeds : Embeddings
        Embeddings to write
    """
    with open(file, 'wb') as outf:
        if not isinstance(embeds.vocab, (FastTextVocab, SimpleVocab)):
            raise ValueError(
                f'Expected FastTextVocab or SimpleVocab, not: {type(embeds.vocab).__name__}'
            )
        _write_binary(outf, "<ii", _FT_MAGIC, 12)
        _write_ft_cfg(outf, embeds)
        _write_ft_vocab(outf, embeds.vocab)
        _write_binary(outf, "<?QQ", 0, *embeds.storage.shape)
        if isinstance(embeds.vocab, SimpleVocab):
            _write_ft_storage_simple(outf, embeds)
        else:
            _write_ft_storage_subwords(outf, embeds)
        _serialize_array_as_le(outf, embeds.storage)


def _read_ft_header(file: BinaryIO):
    """
    Helper method to verify version and magic.
    """
    magic, version = _read_required_binary(file, "<ii")
    if magic != _FT_MAGIC:
        raise ValueError(f"Magic should be 793_712_314, not: {magic}")
    if version != 12:
        raise ValueError(f"Expected version 12, not: {version}")


def _read_ft_cfg(file: BinaryIO) -> Metadata:
    """
    Constructs metadata from fastText config.
    """
    cfg = list(_read_required_binary(file, "<12id"))
    losses = ['HierarchicalSoftmax', 'NegativeSampling', 'Softmax']
    cfg[6] = losses[cfg[6] - 1]
    models = ['CBOW', 'SkipGram', 'Supervised']
    cfg[7] = models[cfg[7] - 1]
    return Metadata(dict(zip(_FT_REQUIRED_CFG_KEYS, cfg)))


def _read_ft_vocab(file: BinaryIO, buckets: int, min_n: int,
                   max_n: int) -> Union[FastTextVocab, SimpleVocab]:
    """
    Helper method to read a vocab from a fastText file

    Returns a SimpleVocab if min_n is 0, otherwise FastTextVocab is returned.
    """
    # discard n_words
    vocab_size, _n_words, n_labels = _read_required_binary(file, "<iii")
    if n_labels:
        raise NotImplementedError(
            "fastText prediction models are not supported")
    # discard n_tokens
    _read_required_binary(file, "<q")

    prune_idx_size = _read_required_binary(file, "<q")[0]
    if prune_idx_size > 0:
        raise NotImplementedError("Pruned vocabs are not supported")

    if min_n:
        return _read_ft_subwordvocab(file, buckets, min_n, max_n, vocab_size)
    return SimpleVocab([_read_binary_word(file) for _ in range(vocab_size)])


def _read_ft_subwordvocab(file: BinaryIO, buckets: int, min_n: int, max_n: int,
                          vocab_size: int) -> FastTextVocab:
    """
    Helper method to build a FastTextVocab from a fastText file.
    """
    words = [_read_binary_word(file) for _ in range(vocab_size)]
    indexer = FastTextIndexer(buckets, min_n, max_n)
    return FastTextVocab(words, indexer)


def _read_binary_word(file: BinaryIO) -> str:
    """
    Helper method to read null-terminated binary strings.
    """
    word = bytearray()
    while True:
        byte = file.read(1)
        if byte == b'\x00':
            break
        if byte == b'':
            raise EOFError
        word.extend(byte)
    # discard frequency
    _ = _read_required_binary(file, "<q")
    entry_type = _read_required_binary(file, "b")[0]
    if entry_type != 0:
        raise ValueError(f'Non word entry: {word}')

    # pylint: disable=fixme # XXX handle unicode errors
    return word.decode("utf8")


def _read_ft_storage(file: BinaryIO, vocab: Vocab) -> NdArray:
    """
    Helper method to read fastText storage.

    If vocab is a SimpleVocab, the matrix is read and returned as is.
    If vocab is a FastTextVocab, the word representations are precomputed based
    on the vocab.
    """
    quantized = _read_required_binary(file, "?")[0]
    if quantized:
        raise NotImplementedError(
            "Quantized storage is not supported for fastText models")
    rows, cols = _read_required_binary(file, "<qq")
    matrix = np.fromfile(file=file, count=rows * cols,
                         dtype=np.float32).reshape((rows, cols))
    if sys.byteorder == 'big':
        matrix.byteswap(inplace=True)
    if isinstance(vocab, FastTextVocab):
        _precompute_word_vecs(vocab, matrix)
    return NdArray(matrix)


def _precompute_word_vecs(vocab: FastTextVocab, matrix: np.ndarray):
    """
    Helper method to precompute word vectors.

    Averages the distinct word representation and the corresponding ngram
    embeddings.
    """
    for i, word in enumerate(vocab):
        indices = [i]
        if isinstance(vocab, FastTextVocab):
            subword_indices = cast(
                List[int], vocab.subword_indices(word, with_ngrams=False))
            indices += subword_indices
        matrix[i] = matrix[indices].mean(0, keepdims=False)


def _write_ft_cfg(file: BinaryIO, embeds: Embeddings):
    """
    Helper method to write fastText config.

    * dims: taken from embeds
    * window_size: -1 if unspecified
    * min_count:  -1 if unspecified
    * ns:  -1 if unspecified
    * word_ngrams:  1
    * loss: one of `['HierarchicalSoftmax', 'NegativeSampling', 'Softmax']`, defaults to 'Softmax'
    * model: one of `['CBOW', 'SkipGram', 'Supervised']`, defaults to SkipGram
    * buckets: taken from embeds, 0 if SimpleVocab
    * min_n: taken from embeds, 0 if SimpleVocab
    * max_n: taken from embeds, 0 if SimpleVocab
    * lr_update_rate: -1 if unspecified
    * sampling_threshold: -1 if unspecified

    loss and model values are overwritten by the default if they are not listed above.
    """
    # declare some dummy values that we can't get from embeds
    meta = {
        'window_size': -1,
        'epoch': -1,
        'min_count': -1,
        'ns': -1,
        'word_ngrams': 1,
        'loss': 'Softmax',
        # fastText uses an integral enum with vals 1, 2, 3, so we can't use
        # a placeholder for unknown models which maps to e.g. 0.
        'model': 'SkipGram',
        'lr_update_rate': -1,
        'sampling_threshold': -1
    }  # type: Dict[str, Any]
    if embeds.metadata is not None:
        meta.update(embeds.metadata)
    meta['dims'] = embeds.storage.shape[1]
    if isinstance(embeds.vocab, FastTextVocab):
        meta['min_n'] = embeds.vocab.min_n
        meta['max_n'] = embeds.vocab.max_n
        meta['buckets'] = embeds.vocab.subword_indexer.n_buckets
    else:
        meta['min_n'] = 0
        meta['max_n'] = 0
        meta['buckets'] = 0
    cfg = [meta[k] for k in _FT_REQUIRED_CFG_KEYS]
    # see explanation above why we need to select some known value
    losses = {'HierarchicalSoftmax': 1, 'NegativeSampling': 2, 'Softmax': 3}
    cfg[6] = losses.get(cfg[6], 3)
    models = {'CBOW': 1, 'SkipGram': 2, 'Supervised': 3}
    cfg[7] = models.get(cfg[7], 2)
    _write_binary(file, "<12id", *cfg)


def _write_ft_vocab(outf: BinaryIO, vocab: Vocab):
    """
    Helper method to write a vocab to fastText.
    """
    # assumes that vocab_size == word_size if n_labels == 0
    _write_binary(outf, "<iii", len(vocab), len(vocab), 0)
    # we discard n_tokens, serialize as 0, no pruned vocabs exist, also 0
    _write_binary(outf, "<qq", 0, 0)
    for word in vocab:
        outf.write(word.encode("utf-8"))
        outf.write(b'\x00')
        # we don't store frequency, also set to 0
        _write_binary(outf, "<q", 0)
        # all entries are words = 0
        _write_binary(outf, "b", 0)


def _write_ft_storage_subwords(outf: BinaryIO, embeds: Embeddings):
    """
    Helper method to write a storage with subwords.

    Restores the original embedding format of fastText, i.e. precomputation is
    undone and unnormalizes the embeddings.
    """
    vocab = embeds.vocab
    assert isinstance(vocab, FastTextVocab)
    storage = embeds.storage
    norms = embeds.norms
    for i, word in enumerate(vocab):
        indices = vocab.subword_indices(word)
        embed = storage[i]  # type: np.ndarray
        embed = embed * (len(indices) + 1)
        if norms is not None:
            embed *= norms[i]
        sw_embeds = storage[indices]  # type: np.ndarray
        embed -= sw_embeds.sum(0, keepdims=False)
        _serialize_array_as_le(outf, embed)

    _serialize_array_as_le(outf, storage[len(vocab):])


def _write_ft_storage_simple(outf: BinaryIO, embeds: Embeddings):
    """
    Helper method to write storage of a simple vocab model.

    Unnormalizes embeddings.
    """
    storage = embeds.storage
    norms = embeds.norms
    for i in range(storage.shape[0]):
        embed = storage[i]  # type: np.ndarray
        if norms is not None:
            embed = norms[i] * embed
        _serialize_array_as_le(outf, embed)


_FT_REQUIRED_CFG_KEYS = [
    'dims', 'window_size', 'epoch', 'min_count', 'ns', 'word_ngrams', 'loss',
    'model', 'buckets', 'min_n', 'max_n', 'lr_update_rate',
    'sampling_threshold'
]

__all__ = ['load_fasttext', 'write_fasttext']
