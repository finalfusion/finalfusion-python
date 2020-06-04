# finalfusion-python
[![Documentation Status](https://readthedocs.org/projects/finalfusion-python/badge/?version=latest)](https://finalfusion-python.readthedocs.io/en/latest/?badge=latest)

## Introduction

`finalfusion` is a Python package for reading, writing and using 
[finalfusion](https://finalfusion.github.io) embeddings, but also
supports other commonly used embeddings like fastText, GloVe and
word2vec. 

The Python package supports the same types of embeddings as the
[finalfusion-rust crate](https://docs.rs/finalfusion/):

* Vocabulary:
  * No subwords
  * Subwords
* Embedding matrix:
  * Array
  * Memory-mapped
  * Quantized
* Norms
* Metadata

## Installation

The finalfusion module is
[available](https://pypi.org/project/finalfusion/#files) on PyPi for Linux,
Mac and Windows. You can use `pip` to install the module:

~~~shell
$ pip install --upgrade finalfusion
~~~

## Installing from source

Building from source depends on `Cython`. If you install the package using
`pip`, you don't need to explicitly install the dependency since it is
specified in `pyproject.toml`.

~~~shell
$ git clone https://github.com/finalfusion/finalfusion-python
$ cd finalfusion-python
$ pip install .
~~~

If you want to build wheels from source, `wheel` needs to be installed.
It's then possible to build wheels through:

~~~shell
$ python setup.py bdist_wheel
~~~

The wheels can be found in `dist`.

## Package Usage

### Basic usage

~~~python
import finalfusion
# loading from different formats
w2v_embeds = finalfusion.load_word2vec("/path/to/w2v.bin")
text_embeds = finalfusion.load_text("/path/to/embeds.txt")
text_dims_embeds = finalfusion.load_text_dims("/path/to/embeds.dims.txt")
fasttext_embeds = finalfusion.load_fasttext("/path/to/fasttext.bin")
fifu_embeds = finalfusion.load_finalfusion("/path/to/embeddings.fifu")

# serialization to formats works similarly
finalfusion.compat.write_word2vec("to_word2vec.bin", fifu_embeds)

# embedding lookup
embedding = fifu_embeds["Test"]

# reading an embedding into a buffer
import numpy as np
buffer = np.zeros(fifu_embeds.storage.shape[1], dtype=np.float32)
fifu_embeds.embedding("Test", out=buffer)

# similarity and analogy query
sim_query = fifu_embeds.word_similarity("Test")
analogy_query = fifu_embeds.analogy("A", "B", "C")

# accessing the vocab and printing the first 10 words
vocab = fifu_embeds.vocab
print(vocab.words[:10])

# SubwordVocabs give access to the subword indexer:
subword_indexer = vocab.subword_indexer
print(subword_indexer.subword_indices("Test", with_ngrams=True))

# accessing the storage and calculate its dot product with an embedding
res = embedding.dot(fifu_embeds.storage)

# printing metadata
print(fifu_embeds.metadata) 
~~~

### Beyond Embeddings

~~~Python
# load only a vocab from a finalfusion file
from finalfusion import load_vocab
vocab = load_vocab("/path/to/finalfusion_file.fifu")

# serialize vocab to single file
vocab.write("/path/to/vocab_file.fifu.voc")

# more specific loading functions exist
from finalfusion.vocab import load_finalfusion_bucket_vocab
fifu_bucket_vocab = load_finalfusion_bucket_vocab("/path/to/vocab_file.fifu.voc")
~~~

The package supports loading and writing all `finalfusion` chunks this way.
This is only supported by the Python package, reading will fail with e.g.
the `finalfusion-rust`.

## Scripts

`finalfusion` also includes a conversion script `ffp-convert` to convert
between the supported formats.
~~~shell
# convert from fastText format to finalfusion
$ ffp-convert -f fasttext fasttext.bin -t finalfusion embeddings.fifu
~~~

`ffp-bucket-to-explicit` can be used to convert bucket embeddings to embeddings
with an explicit ngram lookup.
~~~shell
# convert finalfusion bucket embeddings to explicit
$ ffp-bucket-to-explicit -f finalfusion embeddings.fifu explicit.fifu
~~~ 

Finally, the package comes with `ffp-similar` and `ffp-analogy` to do
analogy and similarity queries.
~~~shell
# get the 5 nearest neighbours of "Tübingen"
$ echo Tübingen | ffp-similar embeddings.fifu
# get the 5 top answers for "Tübingen" is to "Stuttgart" like "Heidelberg" to...
$ echo Tübingen Stuttgart Heidelberg | ffp-analogy embeddings.fifu
~~~

## Where to go from here

  * [documentation](https://finalfusion-python.readthedocs.io/en/0.7.0)
  * [finalfrontier](https://finalfusion.github.io/finalfrontier)
  * [finalfusion](https://finalfusion.github.io/)
  * [pretrained embeddings](https://finalfusion.github.io/pretrained)
