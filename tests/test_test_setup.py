import numpy as np


def test_vocab_array_tuple_fixture(vocab_array_tuple):
    v, m = vocab_array_tuple
    assert v == ["one", "two", "three", "four", "five", "six", "seven"]
    target_list = [[3.0, 1.0, 0.0, 0.0, 0.0, 0.0, 2.0, 2.0, 4.0, 3.0],
                   [2.0, 3.0, 3.0, 3.0, 3.0, 2.0, 0.0, 3.0, 3.0, 4.0],
                   [0.0, 0.0, 2.0, 0.0, 2.0, 1.0, 2.0, 4.0, 0.0, 3.0],
                   [1.0, 4.0, 4.0, 2.0, 4.0, 2.0, 4.0, 1.0, 3.0, 1.0],
                   [0.0, 4.0, 1.0, 2.0, 0.0, 4.0, 0.0, 3.0, 1.0, 3.0],
                   [3.0, 3.0, 4.0, 2.0, 0.0, 0.0, 0.0, 3.0, 2.0, 1.0],
                   [1.0, 4.0, 0.0, 2.0, 2.0, 2.0, 4.0, 3.0, 1.0, 1.0]]
    target = np.array(target_list, dtype=np.float32)
    assert np.allclose(m, target)


def test_fifu_bucket_vocab_fixture(bucket_vocab_embeddings_fifu):
    assert bucket_vocab_embeddings_fifu.vocab.words == ["one", "</s>"]
    assert bucket_vocab_embeddings_fifu.vocab.subword_indexer.upper_bound == 2**10
    assert bucket_vocab_embeddings_fifu.vocab.subword_indexer.buckets_exp == 10
    assert bucket_vocab_embeddings_fifu.vocab.upper_bound == 2 + 2**10
    assert np.allclose(bucket_vocab_embeddings_fifu.norms, [0.11185, 0.24372],
                       atol=1e-5)
    assert bucket_vocab_embeddings_fifu.storage.shape == (2 + 2**10, 5)
