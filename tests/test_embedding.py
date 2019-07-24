import finalfusion
import pytest
import numpy

TEST_NORMS = [
    6.557438373565674,
    8.83176040649414,
    6.164413928985596,
    9.165151596069336,
    7.4833149909973145,
    7.211102485656738,
    7.4833149909973145
]


def test_embeddings_with_norms():
    embeds = finalfusion.Embeddings(
        "tests/embeddings.fifu")
    embeds_dict = dict()
    with open("tests/embeddings.txt", "r", encoding="utf8") as lines:
        for line in lines:
            line_list = line.split(' ')
            embeds_dict[line_list[0]] = [float(val) for val in line_list[1:]]

    for embedding_with_norm, norm in zip(embeds.iter_with_norm(), TEST_NORMS):
        unnormed_embed = embedding_with_norm[1] * norm
        test_embed = embeds_dict[embedding_with_norm[0]]
        assert numpy.allclose(
            unnormed_embed, test_embed), "Embedding from 'iter_with_norm()' fails to match!"
        assert len(
            embedding_with_norm) == 3, "The number of values returned by 'iter_with_norm()' does not match!"


def test_embeddings_with_norms_oov():
    embeds = finalfusion.Embeddings(
        "tests/embeddings.fifu")
    assert embeds.embedding_with_norm("Something out of vocabulary") is None


def test_embeddings():
    embeds = finalfusion.Embeddings(
        "tests/embeddings.fifu")
    embeds_dict = dict()
    with open("tests/embeddings.txt", "r", encoding="utf8") as lines:
        for line in lines:
            line_list = line.split(' ')
            embeds_dict[line_list[0]] = [float(i) for i in line_list[1:]]

    for embedding_with_norm, norm in zip(embeds, TEST_NORMS):
        unnormed_embed = embedding_with_norm[1] * norm
        test_embed = embeds_dict[embedding_with_norm[0]]
        assert numpy.allclose(
            unnormed_embed, test_embed), "Embedding from normal iterator fails to match!"
        assert len(
            embedding_with_norm) == 2, "The number of values returned by normal iterator does not match!"


def test_embeddings_oov():
    embeds = finalfusion.Embeddings(
        "tests/embeddings.fifu")
    assert embeds.embedding("Something out of vocabulary") is None


def test_norms():
    embeds = finalfusion.Embeddings(
        "tests/embeddings.fifu")
    embeds_dict = dict()
    with open("tests/embeddings.txt", "r", encoding="utf8") as lines:
        for line in lines:
            line_list = line.split(' ')
            embeds_dict[line_list[0]] = [float(val) for val in line_list[1:]]

    for embedding_with_norm, norm in zip(embeds.iter_with_norm(), TEST_NORMS):
        assert pytest.approx(
            embedding_with_norm[2] == norm), "Norm fails to match!"
