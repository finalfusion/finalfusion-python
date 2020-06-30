import pytest

from finalfusion.subword import ExplicitIndexer, FinalfusionHashIndexer, FastTextIndexer, ngrams


def test_subword_indices_finalfusion():
    tuebingen_buckets = [
        12, 67, 72, 122, 166, 179, 195, 244, 248, 274, 298, 306, 323, 414, 547,
        588, 646, 649, 705, 715, 759, 815, 818, 855, 858, 1005
    ]
    idx = FinalfusionHashIndexer(10)
    assert idx == idx
    assert idx != FinalfusionHashIndexer(21)
    assert idx != FinalfusionHashIndexer(min_n=2)
    assert idx != FinalfusionHashIndexer(max_n=5)
    assert sorted(idx.subword_indices("tübingen")) == tuebingen_buckets
    with pytest.raises(TypeError):
        _ = idx.subword_indices(None)
    assert idx("<tü") == 818
    assert idx.buckets_exp == 10
    assert idx.upper_bound == 2**10
    assert idx.subword_indices("") == []


def test_subword_indices_fasttext():
    ueberspringen_buckets = [
        79599, 119685, 255527, 263610, 352266, 385524, 403356, 421853, 485366,
        488156, 586161, 619228, 629649, 642367, 716781, 751724, 754367, 771707,
        799583, 887882, 894109, 904527, 908492, 978563, 991164, 992241,
        1142035, 1230973, 1278156, 1350653, 1414694, 1513262, 1533308, 1607098,
        1607788, 1664269, 1712300, 1749574, 1793082, 1891605, 1934955, 1992797
    ]
    idx = FastTextIndexer()
    assert idx == idx
    assert idx != FastTextIndexer(10)
    assert idx != FastTextIndexer(min_n=2)
    assert idx != FastTextIndexer(max_n=4)
    assert sorted(idx.subword_indices("überspringen")) == ueberspringen_buckets
    assert idx.n_buckets == 2_000_000
    assert idx.upper_bound == idx.n_buckets
    assert idx("en>") == 619228
    assert idx.subword_indices("") == []


def test_ngrams():
    assert ngrams("Test") == [
        "<Test>", "<Test", "<Tes", "<Te", "Test>", "Test", "Tes", "est>",
        "est", "st>"
    ]
    assert ngrams("实验", min_n=2) == ["<实验>", "<实验", "<实", "实验>", "实验", "验>"]
    assert ngrams("Test", bracket=False) == ["Test", "Tes", "est"]
    assert ngrams("Test", min_n=5) == ["<Test>", "<Test", "Test>"]
    assert ngrams("", min_n=1, bracket=False) == []
    assert ngrams("Test", min_n=10, max_n=11) == []
    with pytest.raises(OverflowError):
        _ = ngrams("", min_n=-1)
    with pytest.raises(OverflowError):
        _ = ngrams("", min_n=2**32)
    with pytest.raises(TypeError):
        _ = ngrams(2)
    with pytest.raises(TypeError):
        _ = ngrams("Test", "not an int")
    with pytest.raises(AssertionError):
        _ = ngrams("", 0)
    with pytest.raises(AssertionError):
        _ = ngrams("Test", 7)
    with pytest.raises(AssertionError):
        _ = ngrams("Test", 0)
    with pytest.raises(AssertionError):
        _ = ngrams("Test", 3, 0)
    with pytest.raises(AssertionError):
        _ = ngrams("Test", 0, 0)


def test_explicit():
    ngrams10 = [str(i) for i in range(10)]
    indexer = ExplicitIndexer(ngrams10)
    assert indexer.ngrams == ngrams10
    assert indexer.ngram_index == dict((v, i) for i, v in enumerate(ngrams10))
    assert repr(indexer) == "ExplicitIndexer(min_n=3, max_n=6, " \
                            "n_ngrams=10, n_indices=10)"
    assert indexer["0"] == 0
    assert indexer.ngrams[0] == "0"
    assert indexer("0") == 0
    assert indexer("") is None

    ngrams5 = [str(i) for i in range(5)]
    assert ExplicitIndexer(ngrams5) in indexer
    assert ngrams5 in indexer
    assert "0" in indexer
    assert "01" not in indexer
    assert 0 not in indexer


def test_explicit_with_ngram_index():
    ngrams10 = [str(i) for i in range(10)]
    index = dict((v, i) for i, v in enumerate(ngrams10))
    indexer = ExplicitIndexer(ngrams10, ngram_index=index)
    assert indexer.ngrams == ngrams10
    assert indexer.ngram_index == index
    assert indexer["0"] == 0
    assert indexer.ngrams[0] == "0"
    assert indexer("0") == 0


def test_explicit_subword_indices():
    ngrams_test = [
        "<Test>", "<Test", "<Tes", "<Te", "Test>", "Test", "Tes", "est>"
    ]
    indexer = ExplicitIndexer(ngrams_test)
    assert indexer.subword_indices("Test", bracket=True,
                                   with_ngrams=True) == list(
                                       (x, i)
                                       for i, x in enumerate(ngrams_test))
    assert indexer.subword_indices("") == []
    assert indexer.subword_indices("oov") == []
    assert "st>" not in indexer
    with pytest.raises(KeyError):
        _ = indexer["st>"]


def test_explicit_assertions():
    with pytest.raises(AssertionError):
        ExplicitIndexer(["a"] * 2)
    with pytest.raises(AssertionError):
        ExplicitIndexer(["a"], ngram_index={"b": 0})
    with pytest.raises(AssertionError):
        ExplicitIndexer(["a"], ngram_index={"a": 1})
    with pytest.raises(AssertionError):
        ExplicitIndexer(["a"], ngram_index={"a": 0, "b": 1})
    with pytest.raises(AssertionError):
        ExplicitIndexer(["a", "b"], ngram_index={"a": 0, "b": 2})
    with pytest.raises(AssertionError):
        ExplicitIndexer(["a"], ngram_index={"a": 1})
