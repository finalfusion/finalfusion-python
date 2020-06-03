Install
=======

``finalfusion`` is compatible with Python ``3.6`` and more recent versions. Direct dependencies
are `numpy <https://numpy.org/>`__ and `toml <https://github.com/uiri/toml>`__.
Installing for ``3.6`` additionally depends on
`dataclasses <https://github.com/ericvsmith/dataclasses>`__.

Pip
----

From Pypi:

``$ pip install finalfusion``

From GitHub:

``$ pip install git+https://github.com/finalfusion/finalfusion-python``

Source
------

Installing from source requires `Cython <http://docs.cython.org/>`__. When ``finalfusion`` is built
with ``pip``, you don't need to install ``Cython`` manually since the dependency is specified in
``pyproject.toml``.


.. code-block:: bash

   $ git clone https://github.com/finalfusion/finalfusion-python
   $ cd finalfusion-python
   $ pip install . # or python setup.py install

Building a wheel from source is possible if `wheel <https://wheel.readthedocs.io/en/stable/>`__
is installed by:

.. code-block:: bash

   $ git clone https://github.com/finalfusion/finalfusion-python
   $ cd finalfusion-python
   $ python setup.py bdist_wheel
