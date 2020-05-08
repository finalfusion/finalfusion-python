import io
import os

import finalfusion.io


def test_header_roundtrip():
    h = finalfusion.io.Header([
        finalfusion.io.ChunkIdentifier.SimpleVocab,
        finalfusion.io.ChunkIdentifier.NdArray
    ])
    mem_file = io.BytesIO()
    h.write_chunk(mem_file)
    mem_file.seek(0)
    h2 = finalfusion.io.Header.read_chunk(mem_file)
    mem_file.close()
    assert h.chunk_ids == h2.chunk_ids


def test_read_header(tests_root):
    filename = os.path.join(tests_root, "data", "simple_vocab.fifu")
    with open(filename, 'rb') as f:
        h = finalfusion.io.Header.read_chunk(f)
    assert h.chunk_ids == [
        finalfusion.io.ChunkIdentifier.SimpleVocab,
        finalfusion.io.ChunkIdentifier.NdArray
    ]


def test_find_chunk(tests_root):
    filename = os.path.join(tests_root, "data", "simple_vocab.fifu")
    with open(filename, 'rb') as f:
        assert finalfusion.io.ChunkIdentifier.NdArray == finalfusion.io.find_chunk(
            f, [finalfusion.io.ChunkIdentifier.NdArray])
        assert finalfusion.io.find_chunk(
            f, [finalfusion.io.ChunkIdentifier.NdArray
                ]) == finalfusion.io.ChunkIdentifier.NdArray
        assert finalfusion.io.ChunkIdentifier.SimpleVocab == finalfusion.io.find_chunk(
            f, [finalfusion.io.ChunkIdentifier.SimpleVocab])
        assert finalfusion.io.find_chunk(
            f, [finalfusion.io.ChunkIdentifier.BucketSubwordVocab]) is None
        assert finalfusion.io.ChunkIdentifier.SimpleVocab == finalfusion.io.find_chunk(
            f, [
                finalfusion.io.ChunkIdentifier.SimpleVocab,
                finalfusion.io.ChunkIdentifier.NdArray
            ])
        f.seek(-12, 1)
        chunk, _ = finalfusion.io._read_chunk_header(f)
        assert chunk == finalfusion.io.ChunkIdentifier.SimpleVocab
