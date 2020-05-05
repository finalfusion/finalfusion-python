import contextlib
import os

import numpy as np
import pytest

from finalfusion.norms import load_norms, Norms
from finalfusion.io import FinalfusionFormatError


def test_read_array(tests_root):
    with pytest.raises(TypeError):
        load_norms(None)
    with pytest.raises(FinalfusionFormatError):
        load_norms(1)
    with pytest.raises(IOError):
        load_norms("foo")
    n = load_norms(tests_root / "data" / "embeddings.fifu")
    target_norms = np.array([
        6.557438373565674, 8.83176040649414, 6.164413928985596,
        9.165151596069336, 7.4833149909973145, 7.211102485656738,
        7.4833149909973145
    ])
    assert np.allclose(n, target_norms)


def test_norms_roundtrip(tests_root, tmp_path):
    filename = tmp_path / "write_norms.fifu"
    n = load_norms(os.path.join(tests_root, "data", "embeddings.fifu"))
    target_norms = np.array([
        6.557438373565674, 8.83176040649414, 6.164413928985596,
        9.165151596069336, 7.4833149909973145, 7.211102485656738,
        7.4833149909973145
    ])
    assert np.allclose(n, target_norms)

    n.write(filename)
    n2 = load_norms(filename)
    assert n.shape == n2.shape
    assert np.allclose(n, n2)
    assert np.allclose(n, target_norms)


def test_iter_sliced():
    norms = np.float32(np.random.random_sample(10))
    s = Norms(norms)
    for _ in range(250):
        upper = np.random.randint(-len(norms) * 3, len(norms) * 3)
        lower = np.random.randint(-len(norms) * 3, len(norms) * 3)
        step = np.random.randint(-len(norms) * 3, len(norms) * 3)
        if step == 0:
            continue
        for norms_row, norms_row in zip(s[lower:upper:step],
                                        norms[lower:upper:step]):
            assert np.allclose(norms_row, norms_row)


def test_slice_slice():
    for _ in range(250):
        norms = np.float32(np.random.random_sample(100))
        s = Norms(norms)
        assert np.allclose(norms[:], s[:])
        assert np.allclose(norms, s)
        for _ in range(5):
            if len(norms) == 0:
                break
            upper = np.random.randint(-len(norms) * 2, len(norms) * 2)
            lower = np.random.randint(-len(norms) * 2, len(norms) * 2)
            step = np.random.randint(-len(norms) * 2, len(norms) * 2)
            ctx = pytest.raises(
                ValueError) if step == 0 else contextlib.suppress()
            with ctx:
                norms = norms[lower:upper:step]
            with ctx:
                s = s[lower:upper:step]
            assert np.allclose(norms, s)


def test_write_sliced(tmp_path):
    filename = tmp_path / "write_sliced.fifu"
    norms = np.float32(np.random.random_sample(10))
    s = Norms(norms)
    for _ in range(250):
        upper = np.random.randint(-len(norms) * 3, len(norms) * 3)
        lower = np.random.randint(-len(norms) * 3, len(norms) * 3)
        step = np.random.randint(-len(norms) * 3, len(norms) * 3)
        if step == 0:
            continue
        s[lower:upper:step].write(filename)
        s2 = load_norms(filename)
        assert np.allclose(norms[lower:upper:step], s2)


def test_slicing():
    norms = np.float32(np.random.random_sample(10))
    s = Norms(norms)
    assert np.allclose(norms[:], s[:])
    assert np.allclose(norms, s)

    for _ in range(250):
        upper = np.random.randint(-len(norms) * 3, len(norms) * 3)
        lower = np.random.randint(-len(norms) * 3, len(norms) * 3)
        step = np.random.randint(-len(norms) * 3, len(norms) * 3)
        ctx = pytest.raises(ValueError) if step == 0 else contextlib.suppress()

        assert np.allclose(norms[:upper], s[:upper])
        assert np.allclose(norms[lower:upper], s[lower:upper])
        with ctx:
            val = s[lower:upper:step]
        with ctx:
            assert np.allclose(norms[lower:upper:step], val)
        with ctx:
            val = s[:upper:step]
        with ctx:
            assert np.allclose(norms[:upper:step], val)
        with ctx:
            val = s[::step]
        with ctx:
            assert np.allclose(norms[::step], val)
