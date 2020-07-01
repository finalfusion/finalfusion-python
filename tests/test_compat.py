import numpy as np
from finalfusion import Embeddings

from finalfusion.compat import write_word2vec, load_word2vec, write_text, write_text_dims, load_text, load_text_dims, \
    write_fasttext, load_fasttext
from finalfusion.norms import Norms
from finalfusion.storage import NdArray
from finalfusion.vocab import SimpleVocab


def test_w2v_roundtrip(embeddings_w2v, tmp_path):
    filename = tmp_path / "compat_embeddings.w2v"
    write_word2vec(filename, embeddings_w2v)
    w2v = load_word2vec(filename)
    assert w2v.vocab == embeddings_w2v.vocab
    assert np.allclose(w2v.storage, embeddings_w2v.storage)


def test_bucket_to_w2v_roundtrip(bucket_vocab_embeddings_fifu, tmp_path):
    filename = tmp_path / "bucket_to_w2v.w2v"
    write_word2vec(filename, bucket_vocab_embeddings_fifu)
    w2v = load_word2vec(filename)
    assert w2v.vocab.words == bucket_vocab_embeddings_fifu.vocab.words
    assert w2v.vocab.word_index == bucket_vocab_embeddings_fifu.vocab.word_index
    assert np.allclose(w2v.storage,
                       bucket_vocab_embeddings_fifu.storage[:len(w2v.vocab)])
    assert np.allclose(w2v.norms, bucket_vocab_embeddings_fifu.norms)


def test_text_roundtrip(embeddings_text, tmp_path):
    filename = tmp_path / "roundtrip.txt"
    write_text(filename, embeddings_text)
    text = load_text(filename)
    assert text.vocab == embeddings_text.vocab
    assert np.allclose(text.norms, embeddings_text.norms)
    assert np.allclose(text.storage, embeddings_text.storage)


def test_textdims_roundtrip(embeddings_text_dims, tmp_path):
    filename = tmp_path / "roundtrip.txt.dims"
    write_text_dims(filename, embeddings_text_dims)
    text = load_text_dims(filename)
    assert text.vocab == embeddings_text_dims.vocab
    assert np.allclose(text.norms, embeddings_text_dims.norms)
    assert np.allclose(text.storage, embeddings_text_dims.storage)


def test_nonascii_whitespace_text_roundtrip(tmp_path):
    vocab = ["\u00A0"]
    storage = np.ones((1, 5), dtype=np.float32)
    norms = np.linalg.norm(storage, axis=1)
    storage /= norms[:, None]
    embeds = Embeddings(NdArray(storage),
                        SimpleVocab(vocab),
                        norms=Norms(norms))
    filename = tmp_path / "non-ascii.txt"
    write_text(filename, embeds)
    text = load_text(filename)
    assert embeds.vocab == text.vocab, f'{embeds.vocab.words}{text.vocab.words}'
    assert np.allclose(embeds.storage, text.storage)
    assert np.allclose(embeds.norms, text.norms)


def test_fasttext_roundtrip(embeddings_ft, tmp_path):
    filename = tmp_path / "ft_roundtrip.bin"
    write_fasttext(filename, embeddings_ft)
    ft = load_fasttext(filename)
    assert embeddings_ft.vocab == ft.vocab
    assert np.allclose(embeddings_ft.norms, ft.norms)
    for a, b in zip(embeddings_ft.storage, ft.storage):
        assert np.allclose(a, b, atol=1e-5)
