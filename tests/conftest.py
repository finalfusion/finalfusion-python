import pathlib

import pytest
import os

import finalfusion.vocab


@pytest.fixture
def tests_root():
    yield pathlib.PurePath(os.path.dirname(__file__))


@pytest.fixture
def simple_vocab_fifu(tests_root):
    yield finalfusion.vocab.load_vocab(tests_root / "data/simple_vocab.fifu")
