import finalfusion
import pytest


def test_embeddings_with_norms_oov():
    embeds = finalfusion.Embeddings(
        "tests/embeddings.fifu")
    vocab = embeds.vocab()
    assert vocab.item_to_indices("Something out of vocabulary") is None
