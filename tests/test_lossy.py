import pytest

from finalfusion import load_text_dims, load_text, load_word2vec


def test_text_dims_broken_utf8(tests_root):
    e = load_text_dims(tests_root / "data" / "utf8-incomplete.dims",
                       lossy=True)
    assert e.vocab.words == ["meren", "zee�n", "rivieren"]
    with pytest.raises(UnicodeDecodeError):
        _ = load_text_dims(tests_root / "data" / "utf8-incomplete.dims",
                           lossy=False)


def test_text_broken_utf8(tests_root):
    e = load_text(tests_root / "data" / "utf8-incomplete.txt", lossy=True)
    assert e.vocab.words == ["meren", "zee�n", "rivieren"]
    with pytest.raises(UnicodeDecodeError):
        _ = load_text(tests_root / "data" / "utf8-incomplete.txt", lossy=False)


def test_w2v_broken_utf8(tests_root):
    e = load_word2vec(tests_root / "data" / "utf8-incomplete.bin", lossy=True)
    assert e.vocab.words == ["meren", "zee�n", "rivieren"]
    with pytest.raises(UnicodeDecodeError):
        _ = load_word2vec(tests_root / "data" / "utf8-incomplete.bin",
                          lossy=False)
