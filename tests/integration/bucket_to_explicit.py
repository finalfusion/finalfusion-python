import numpy as np

from finalfusion import load_finalfusion
from finalfusion.scripts.util import Format
from finalfusion.subword import ngrams
from finalfusion.vocab.subword import FastTextVocab, ExplicitVocab, FinalfusionBucketVocab


def test(inp, input_format, output):
    e1 = Format(input_format).load(inp, mmap=False, lossy=False)
    e2 = load_finalfusion(output)

    v1 = e1.vocab
    v2 = e2.vocab
    assert isinstance(v1, (FinalfusionBucketVocab, FastTextVocab))
    assert isinstance(v2, ExplicitVocab)
    assert v1.words == v2.words
    assert v1.word_index == v2.word_index
    assert v1.subword_indexer.min_n == v2.subword_indexer.min_n, \
        f"{v1.subword_indexer.min_n} == {v2.subword_indexer.min_n}"
    assert v1.subword_indexer.max_n == v2.subword_indexer.max_n, \
        f"{v1.subword_indexer.max_n} == {v2.subword_indexer.max_n}"
    v1_ngrams = set([ngram for word in v1.words for ngram in ngrams(word)])
    v1_unique_indices = set((v1.subword_indexer(ngram) for ngram in v1_ngrams))
    assert v1_ngrams == set(v2.subword_indexer.ngrams)
    assert len(v1_unique_indices) == v2.subword_indexer.upper_bound, \
        f"{len(v1_unique_indices)} == {v2.subword_indexer.upper_bound}"
    assert len(v1_unique_indices) + len(v1) == v2.upper_bound, \
        f"{len(v1_unique_indices)} + {len(v1)} == {v2.upper_bound}"
    assert e2.storage.shape[0] == v2.upper_bound, \
        f"{e2.storage.shape[0]} == {v2.upper_bound}"
    assert np.allclose(e1.storage[:len(v1)], e2.storage[:len(v2)])
    for ngram in v1_ngrams:
        e1_ngram_embed = e1.storage[v1.subword_indexer(ngram) + len(v1)]
        e2_ngram_embed = e2.storage[v2.subword_indexer(ngram) + len(v1)]
        assert np.allclose(e1_ngram_embed, e2_ngram_embed)


if __name__ == '__main__':
    import sys
    test(*sys.argv[1:])
