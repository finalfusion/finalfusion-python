# finalfrontier-python

## Introduction

finalfrontier-python is a Python module for
[finalfrontier](https://github.com/danieldk/finalfrontier).
finalfrontier-python is still under development, precompiled modules will be
made available in the future.

## Building the module

First, you need `pyo3-pack`:

~~~shell
$ cargo install pyo3-pack
~~~

Now you can build finalfrontier-python in a virtual environment:

~~~shell
$ python3 -m venv ff-env
$ source ff-env/bin/activate
$ pyo3-pack develop --release
~~~

To build a wheel:

~~~shell
$ pyo3-pack build --release
~~~

## Usage

A finalfrontier model can be loaded as follows:

~~~python
import finalfrontier
model = finalfrontier.Model("/Users/daniel/git/finalfrontier/throwaway.bin")
~~~

You can then compute an embedding, perform similarity queries, or analogy
queries:

~~~python
e = model.embedding("Tübingen")
model.similarity("Tübingen")
model.analogy("Berlin", "Deutschland", "Amsterdam")
~~~


## Where to go from here

  * [finalfrontier](https://github.com/danieldk/finalfrontier)
