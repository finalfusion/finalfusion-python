import pytest
import finalfusion.vocab

from finalfusion.io import FinalfusionFormatError
from finalfusion.subword import FinalfusionHashIndexer, FastTextIndexer
from finalfusion.vocab import FinalfusionBucketVocab, SimpleVocab, load_vocab, FastTextVocab


def test_reading(tests_root):
    with pytest.raises(TypeError):
        finalfusion.vocab.load_vocab(None)
    with pytest.raises(FinalfusionFormatError):
        # 0 opens sys.stdin, should result in an error when trying to read magic
        finalfusion.vocab.load_vocab(0)
    with pytest.raises(IOError):
        finalfusion.vocab.load_vocab("foo")
    vocab_path = tests_root / "data" / "simple_vocab.fifu"
    v = load_vocab(vocab_path)
    assert v.words[0] == "Paris"


def test_contains():
    v = finalfusion.vocab.SimpleVocab([str(i) for i in range(10)])
    assert "1" in v
    assert None not in v
    assert ["1", "2"] in v
    assert {"1", "2"} in v
    assert map(str, range(2)) in v
    assert not range(2) in v


def test_simple_roundtrip(tests_root, tmp_path):
    filename = tmp_path / "write_simple.fifu"
    v = load_vocab(tests_root / "data" / "simple_vocab.fifu")
    v.write(filename)
    assert load_vocab(filename)


def test_simple_constructor():
    v = SimpleVocab([str(i) for i in range(10)])
    assert [v[str(i)] for i in range(10)] == [i for i in range(10)]
    with pytest.raises(AssertionError):
        SimpleVocab(["a"] * 2)
    assert len(v) == 10
    assert v.upper_bound == len(v)


def test_simple_eq():
    v = SimpleVocab([str(i) for i in range(10)])
    assert v == v
    with pytest.raises(TypeError):
        _ = v > v
    with pytest.raises(TypeError):
        _ = v >= v
    with pytest.raises(TypeError):
        _ = v <= v
    with pytest.raises(TypeError):
        _ = v < v
    v2 = SimpleVocab([str(i + 1) for i in range(10)])
    assert v != v2
    assert v in v


def test_string_idx(simple_vocab_fifu):
    assert simple_vocab_fifu["Paris"] == 0


def test_string_oov(simple_vocab_fifu):
    with pytest.raises(KeyError):
        _ = simple_vocab_fifu["definitely in vocab"]


def test_fifu_buckets_constructor():
    v = FinalfusionBucketVocab([str(i) for i in range(10)])
    assert [v[str(i)] for i in range(10)] == [i for i in range(10)]
    with pytest.raises(AssertionError):
        v = FinalfusionBucketVocab(["a"] * 2)
    with pytest.raises(AssertionError):
        _ = FinalfusionBucketVocab(v.words, FastTextIndexer(21))
    assert len(v) == 10
    assert v.upper_bound == len(v) + pow(2, 21)
    assert v == v
    assert v in v
    assert v != SimpleVocab(v.words)
    assert v != FinalfusionBucketVocab(v.words, FinalfusionHashIndexer(20))
    assert repr(v) == f"FinalfusionBucketVocab(\n" \
                      f"\tindexer={repr(v.subword_indexer)}\n" \
                      "\twords=[...]\n" \
                      "\tword_index={{...}}\n" \
                      ")"


def test_fasttext_constructor():
    v = FastTextVocab([str(i) for i in range(10)])
    assert [v[str(i)] for i in range(10)] == [i for i in range(10)]
    with pytest.raises(AssertionError):
        v = FastTextVocab(["a"] * 2)
    with pytest.raises(AssertionError):
        _ = FastTextVocab(v.words, FinalfusionHashIndexer(21))
    assert len(v) == 10
    assert v.upper_bound == len(v) + 2_000_000
    assert v == v
    assert v in v
    assert v != SimpleVocab(v.words)
    assert v != FastTextVocab(v.words, FastTextIndexer(20))
    assert repr(v) == f"FastTextVocab(\n" \
                      f"\tindexer={repr(v.subword_indexer)}\n" \
                      "\twords=[...]\n" \
                      "\tword_index={{...}}\n" \
                      ")"


def test_fasttext_vocab_roundtrip(tmp_path):
    filename = tmp_path / "write_ft_vocab.fifu"
    v = FastTextVocab([str(i) for i in range(10)])
    v.write(filename)
    v2 = load_vocab(filename)
    assert v == v2


def test_fifu_buckets_roundtrip(tests_root, tmp_path):
    filename = tmp_path / "write_ff_buckets.fifu"
    v = load_vocab(tests_root / "data" / "ff_buckets.fifu")
    v.write(filename)
    assert v == load_vocab(filename)


def test_ff_buckets_lookup(tests_root):
    v = load_vocab(tests_root / "data" / "ff_buckets.fifu")
    assert v.words[0] == "one"
    assert v["one"] == 0
    tuebingen_buckets = [
        14, 69, 74, 124, 168, 181, 197, 246, 250, 276, 300, 308, 325, 416, 549,
        590, 648, 651, 707, 717, 761, 817, 820, 857, 860, 1007
    ]
    assert sorted(v.idx('tübingen')) == tuebingen_buckets
