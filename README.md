# finalfusion-python

## Introduction

`finalfusion-python` is a Python module for reading, writing, and
using *finalfusion* embeddings. This module is implemented in Rust as
a wrapper around the [rust2vec](https://github.com/danieldk/rust2vec)
crate. The Python module supports the same types of finalfusion
embeddings as rust2vec:

* Vocabulary:
  * No subwords
  * Subwords
* Embedding matrix:
  * Array
  * Memory-mapped
  * Quantized

## Building the module

First, you need `pyo3-pack`:

~~~shell
$ cargo install pyo3-pack
~~~

Now you can build finalfusion-python in a virtual environment:

~~~shell
$ python3 -m venv ff-env
$ source ff-env/bin/activate
$ pyo3-pack develop --release
~~~

To build a wheel:

~~~shell
$ pyo3-pack build --release
~~~

## Getting embeddings

rust2vec uses its own embedding format, which supports memory mapping,
subword units, and quantized matrices. GloVe and word2vec embeddings
can be converted using rust2vec's `r2v-convert` utility.

Embeddings trained with
[finalfrontier](https://github.com/danieldk/finalfrontier) version
0.4.0 and later are in finalfusion format and can be used directly
with this Python module.

## Usage

finalfusion embeddings can be loaded as follows:

~~~python
import finalfusion
embeds = finalfusion.Embeddings("/Users/daniel/twe.fifu")

# Or if you want to memory-map the embedding matrix:
embeds = finalfusion.Embeddings("/Users/daniel/twe.fifu", mmap=True)
~~~

You can then compute an embedding, perform similarity queries, or analogy
queries:

~~~python
e = embeds.embedding("Tübingen")
embeds.similarity("Tübingen")
embeds.analogy("Berlin", "Deutschland", "Amsterdam")
~~~

## Where to go from here

  * [finalfrontier](https://github.com/danieldk/finalfrontier)
  * [rust2vec](https://github.com/danieldk/rust2vec)
