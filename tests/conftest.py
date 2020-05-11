import os
import pathlib

import numpy as np
import pytest

import finalfusion.vocab


@pytest.fixture
def tests_root():
    yield pathlib.PurePath(os.path.dirname(__file__))


@pytest.fixture
def simple_vocab_fifu(tests_root):
    yield finalfusion.vocab.load_vocab(tests_root / "data/simple_vocab.fifu")


@pytest.fixture
def vocab_array_tuple(tests_root):
    with open(tests_root / "data" / "embeddings.txt") as f:
        lines = f.readlines()
        v = []
        m = []
        for line in lines:
            line = line.split()
            v.append(line[0])
            m.append([float(p) for p in line[1:]])
    yield v, np.array(m, dtype=np.float32)


@pytest.fixture
def embeddings_fifu(tests_root):
    yield finalfusion.load_finalfusion(tests_root / "data" / "embeddings.fifu",
                                       mmap=False)
