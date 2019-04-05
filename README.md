# finalfusion-python

## Introduction

`finalfusion-python` is a Python module for reading, writing, and
using *finalfusion* embeddings. This module is implemented in Rust as
a wrapper around the [finalfusion](https://docs.rs/finalfusion/)
crate. The Python module supports the same types of finalfusion
embeddings:

* Vocabulary:
  * No subwords
  * Subwords
* Embedding matrix:
  * Array
  * Memory-mapped
  * Quantized

## Installation

The finalfusion module is
[available](https://pypi.org/project/finalfusion/#files) on PyPi for some
platforms. You can use `pip` to install the module:

~~~shell
$ pip install --upgrade finalfusion
~~~

## Building from source

finalfusion can also be built from source. This requires a Rust toolchain
that is installed through rustup. First, you need `pyo3-pack`:

~~~shell
$ cargo install pyo3-pack
~~~

finalfusion currently requires a nightly version of Rust. You can use rustup
to switch to a nightly build:

~~~shell
# Use the nightly toolchain in the current directory.
$ rustup override set nightly
~~~

Now you can build finalfusion-python wheels for Python versions that are
detected by `pyo3-pack`:

~~~shell
$ pyo3-pack build --release
~~~

The wheels are then in the `target/wheels` directory.

## Getting embeddings

finalfusion uses its own embedding format, which supports memory mapping,
subword units, and quantized matrices. GloVe and word2vec embeddings
can be converted using finalfusion's `ff-convert` utility.

Embeddings trained with
[finalfrontier](https://github.com/finalfusion/finalfrontier) version
0.4.0 and later are in finalfusion format and can be used directly
with this Python module.

## Usage

finalfusion embeddings can be loaded as follows:

~~~python
import finalfusion
embeds = finalfusion.Embeddings("myembeddings.fifu")

# Or if you want to memory-map the embedding matrix:
embeds = finalfusion.Embeddings("myembeddings", mmap=True)
~~~

You can then compute an embedding, perform similarity queries, or analogy
queries:

~~~python
e = embeds.embedding("Tübingen")
embeds.similarity("Tübingen")
embeds.analogy("Berlin", "Deutschland", "Amsterdam")
~~~

More usage examples can be found in the
[examples](https://github.com/finalfusion/finalfusion-python/tree/master/examples)
directory.

## Where to go from here

  * [finalfrontier](https://finalfusion.github.io/finalfrontier)
  * [finalfusion](https://finalfusion.io/)
  * [pretrained embeddings](https://finalfusion.github.io/pretrained)
