import os

import finalfusion
import numpy
import pytest


@pytest.fixture
def analogy_fifu(tests_root):
    yield finalfusion.Embeddings(os.path.join(tests_root, "analogy.fifu"))


@pytest.fixture
def embeddings_fifu(tests_root):
    yield finalfusion.Embeddings(os.path.join(tests_root, "embeddings.fifu"))


@pytest.fixture
def embeddings_text(tests_root):
    embeds = dict()

    with open(os.path.join(tests_root, "embeddings.txt"), "r", encoding="utf8") as lines:
        for line in lines:
            line_list = line.split(' ')
            embeds[line_list[0]] = numpy.array(
                [float(c) for c in line_list[1:]])

    yield embeds


@pytest.fixture
def similarity_fifu(tests_root):
    yield finalfusion.Embeddings(os.path.join(tests_root, "similarity.fifu"))


@pytest.fixture
def tests_root():
    yield os.path.dirname(__file__)
