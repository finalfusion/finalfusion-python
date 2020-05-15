import pytest

from finalfusion.subword import FinalfusionHashIndexer, FastTextIndexer


def test_subword_indices_finalfusion():
    tuebingen_buckets = [
        12, 67, 72, 122, 166, 179, 195, 244, 248, 274, 298, 306, 323, 414, 547,
        588, 646, 649, 705, 715, 759, 815, 818, 855, 858, 1005
    ]
    idx = FinalfusionHashIndexer(10)
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
    assert sorted(idx.subword_indices("überspringen")) == ueberspringen_buckets
    assert idx.n_buckets == 2_000_000
    assert idx.upper_bound == idx.n_buckets
    assert idx("en>") == 619228
    assert idx.subword_indices("") == []
