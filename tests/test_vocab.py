import pytest
import finalfusion.vocab

from finalfusion.io import FinalfusionFormatError


def test_reading(tests_root):
    with pytest.raises(TypeError):
        finalfusion.vocab.load_vocab(None)
    with pytest.raises(FinalfusionFormatError):
        # 0 opens sys.stdin, should result in an error when trying to read magic
        finalfusion.vocab.load_vocab(0)
    with pytest.raises(IOError):
        finalfusion.vocab.load_vocab("foo")
    vocab_path = tests_root / "data" / "simple_vocab.fifu"
    v = finalfusion.vocab.load_vocab(vocab_path)
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
    v = finalfusion.vocab.load_vocab(tests_root / "data" / "simple_vocab.fifu")
    v.write(filename)
    assert v == finalfusion.vocab.load_vocab(filename)


def test_simple_constructor():
    v = finalfusion.vocab.SimpleVocab([str(i) for i in range(10)])
    assert [v[str(i)] for i in range(10)] == [i for i in range(10)]
    with pytest.raises(ValueError):
        finalfusion.vocab.SimpleVocab(["a"] * 2)
    assert len(v) == 10
    assert v.idx_bound == len(v)


def test_simple_eq():
    v = finalfusion.vocab.SimpleVocab([str(i) for i in range(10)])
    assert v == v
    with pytest.raises(TypeError):
        _ = v > v
    with pytest.raises(TypeError):
        _ = v >= v
    with pytest.raises(TypeError):
        _ = v <= v
    with pytest.raises(TypeError):
        _ = v < v
    v2 = finalfusion.vocab.SimpleVocab([str(i + 1) for i in range(10)])
    assert v != v2
    assert v in v


def test_string_idx(simple_vocab_fifu):
    assert simple_vocab_fifu["Paris"] == 0


def test_string_oov(simple_vocab_fifu):
    with pytest.raises(KeyError):
        _ = simple_vocab_fifu["definitely in vocab"]
