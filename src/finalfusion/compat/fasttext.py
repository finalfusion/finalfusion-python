"""
Fasttext IO compat module.
"""

import sys
from os import PathLike
from typing import Union, BinaryIO, cast, List

import numpy as np

from finalfusion._util import _normalize_matrix
from finalfusion.embeddings import Embeddings
from finalfusion.io import _read_required_binary, _write_binary, _serialize_array_as_le
from finalfusion.metadata import Metadata
from finalfusion.storage import NdArray
from finalfusion.subword import FastTextIndexer
from finalfusion.vocab import FastTextVocab, Vocab, SimpleVocab

_FT_MAGIC = 793_712_314


def load_fasttext(file: Union[str, bytes, int, PathLike],
                  lossy: bool = False) -> Embeddings:
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
    lossy : bool
        If set to true, malformed UTF8 sequences in words will be replaced with the `U+FFFD`
        REPLACEMENT character.

    Returns
    -------
    embeddings : Embeddings
        The embeddings from the input file.
    """
    with open(file, 'rb') as inf:
        _read_ft_header(inf)
        metadata = _read_ft_cfg(inf)
        vocab = _read_ft_vocab(inf, metadata['buckets'], metadata['min_n'],
                               metadata['max_n'], lossy)
        storage = _read_ft_storage(inf, vocab)
        norms = _normalize_matrix(storage[:len(vocab)])
    return Embeddings(storage=storage,
                      vocab=vocab,
                      norms=norms,
                      metadata=metadata,
                      origin=inf.name)


def write_fasttext(file: Union[str, bytes, int, PathLike], embeds: Embeddings):
    """
    Write embeddings in fastText format.

    Only embeddings with fastText vocabulary can be written to fastText format.

    fastText models require values for all config keys, some of these can be inferred from
    finalfusion models others are assigned some default values:

        * dims: inferred from model
        * window_size: 0
        * min_count: 0
        * ns: 0
        * word_ngrams: 1
        * loss: HierarchicalSoftmax
        * model: CBOW
        * buckets: inferred from model
        * min_n: inferred from model
        * max_n: inferred from model
        * lr_update_rate: 0
        * sampling_threshold: 0

    Some information from original fastText models gets lost e.g.:
        * word frequencies
        * n_tokens

    Embeddings are un-normalized before serialization: if norms are present, each embedding is
    scaled by the associated norm. Additionally, the original state of the embedding matrix is
    restored, precomputation and l2-normalization of word embeddings is undone.

    Parameters
    ----------
    file : str, bytes, int, PathLike
        Output file
    embeds : Embeddings
        Embeddings to write
    """
    with open(file, 'wb') as outf:
        vocab = embeds.vocab
        if not isinstance(vocab, FastTextVocab):
            raise ValueError(
                f'Expected FastTextVocab, not: {type(embeds.vocab).__name__}')
        _write_binary(outf, "<ii", _FT_MAGIC, 12)
        _write_ft_cfg(outf, embeds.dims, vocab.subword_indexer.n_buckets,
                      vocab.min_n, vocab.max_n)
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


def _read_ft_vocab(file: BinaryIO, buckets: int, min_n: int, max_n: int,
                   lossy: bool) -> Union[FastTextVocab, SimpleVocab]:
    """
    Helper method to read a vocab from a fastText file

    Returns a FastTextVocab.
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

    words = [_read_binary_word(file, lossy) for _ in range(vocab_size)]
    indexer = FastTextIndexer(buckets, min_n, max_n)
    return FastTextVocab(words, indexer)


def _read_binary_word(file: BinaryIO, lossy: bool) -> str:
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

    return word.decode('utf8', errors='replace' if lossy else 'strict')


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


def _write_ft_cfg(file: BinaryIO, dims: int, n_buckets: int, min_n: int,
                  max_n: int):
    """
    Helper method to write fastText config.

    The following values are used:

    * dims: passed as arg
    * window_size: 0
    * min_count:  0
    * ns:  0
    * word_ngrams:  1
    * loss: HierarchicalSoftmax
    * model: CBOW
    * buckets: passed as arg
    * min_n: passed as arg
    * max_n: passed as arg
    * lr_update_rate: 0
    * sampling_threshold: 0
    """
    # declare some dummy values that we can't get from embeds
    cfg = [
        dims,  # dims
        0,  # window_size
        0,  # epoch
        0,  # mincount
        0,  # ns
        1,  # word_ngrams
        1,  # loss, defaults to hierarchical_softmax
        1,  # model, defaults to CBOW
        n_buckets,  # buckets
        min_n,  # min_n
        max_n,  # max_n
        0,  # lr_update_rate
        0,  # sampling_threshold
    ]
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
