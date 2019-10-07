# finalfusion-python

## Introduction

`finalfusion-python` is a Python module for reading, writing, and
using *finalfusion* embeddings, but also offers methods to read
and use fastText, word2vec and GloVe embeddings. This module is
implemented in Rust as a wrapper around the 
[finalfusion](https://docs.rs/finalfusion/) crate. 

The Python module supports the same types of embeddings:

* Vocabulary:
  * No subwords
  * Subwords
* Embedding matrix:
  * Array
  * Memory-mapped
  * Quantized
* Format:
  * finalfusion
  * fastText
  * word2vec
  * GloVe

## Installation

The finalfusion module is
[available](https://pypi.org/project/finalfusion/#files) on PyPi for some
platforms. You can use `pip` to install the module:

~~~shell
$ pip install --upgrade finalfusion
~~~

## Building from source

finalfusion can also be built from source. This requires a Rust toolchain
that is installed through rustup. First, you need `maturin`:

~~~shell
$ cargo install maturin
~~~

finalfusion currently requires a nightly version of Rust. You can use rustup
to switch to a nightly build:

~~~shell
# Use the nightly toolchain in the current directory.
$ rustup override set nightly
~~~

Now you can build finalfusion-python wheels for Python versions that are
detected by `maturin`:

~~~shell
$ maturin build --release
~~~

The wheels are then in the `target/wheels` directory.

## Getting embeddings

finalfusion uses its own embedding format, which supports memory mapping,
subword units, and quantized matrices. Moreover, finalfusion can read
fastText, GloVe and word2vec embeddings, but does not support memory
mapping those formats. Such embedddings can be converted to finalfusion
format using 
[finalfusion-utils'](https://github.com/finalfusion/finalfusion-utils)
`convert`.

Embeddings trained with
[finalfrontier](https://github.com/finalfusion/finalfrontier) version
0.4.0 and later are in finalfusion format and can be used directly
with this Python module.

## Usage

Embeddings can be loaded as follows:

~~~python
import finalfusion
# Loading embeddings in finalfusion format
embeds = finalfusion.Embeddings("myembeddings.fifu")

# Or if you want to memory-map the embedding matrix:
embeds = finalfusion.Embeddings("myembeddings.fifu", mmap=True)

# fastText format
embeds = finalfusion.Embeddings.read_fasttext("myembeddings.bin")

# word2vec format
embeds = finalfusion.Embeddings.read_word2vec("myembeddings.w2v")
~~~

You can then compute an embedding, perform similarity queries, or analogy
queries:

~~~python
e = embeds.embedding("Tübingen")
# default similarity query for "Tübingen"
embeds.word_similarity("Tübingen")

# similarity query based on a vector, returning the closest embedding to
# the input vector, skipping "Tübingen"
embeds.embeddings_similarity(e, skip={"Tübingen"})

# default analogy query
embeds.analogy("Berlin", "Deutschland", "Amsterdam")

# analogy query allowing "Deutschland" as answer
embeds.analogy("Berlin", "Deutschland", "Amsterdam", mask=(True,False,True))
~~~

If you want to operate directly on the full embedding matrix, you can
get a copy of this matrix through:
~~~python
# get copy of embedding matrix, changes to this won't touch the original matrix
e.matrix_copy()
~~~

Finally access to the vocabulary is provided through:
~~~python
v = e.vocab()
# get a list of indices associated with "Tübingen"
v.item_to_indices("Tübingen")

# get a list of `(ngram, index)` tuples for "Tübingen"
v.ngram_indices("Tübingen")

# get a list of subword indices for "Tübingen"
v.subword_indices("Tübingen")
~~~

More usage examples can be found in the
[examples](https://github.com/finalfusion/finalfusion-python/tree/master/examples)
directory.

## Where to go from here

  * [finalfrontier](https://finalfusion.github.io/finalfrontier)
  * [finalfusion](https://finalfusion.github.io/)
  * [pretrained embeddings](https://finalfusion.github.io/pretrained)
