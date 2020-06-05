import sys
import os
import pathlib

from setuptools import find_packages, setup, Extension
from setuptools.command.build_ext import build_ext

this_directory = os.path.abspath(os.path.dirname(__file__))
with open(os.path.join(this_directory, 'README.md'), encoding='utf-8') as f:
    long_description = f.read()

class cython_build_ext(build_ext):
    user_options = build_ext.user_options + [
        ('annotate', None,
         'Generate HTML files with Python overhead annotation for Cython')
    ]

    def initialize_options(self):
        build_ext.initialize_options(self)
        self.annotate = False

    def finalize_options(self):
        build_ext.finalize_options(self)
        if self.annotate:
            self.force = True

    def run(self):
        build_ext.run(self)


abs_path = pathlib.Path(__file__).absolute()
c_paths = [
    abs_path / "src/finalfusion/subword/hash_indexers.c",
    abs_path / "src/finalfusion/subword/ngrams.c",
    abs_path / "src/finalfusion/subword/explicit_indexer.c"
]
# cython is needed if not all extensions have been cythonized
need_cython = not all(map(os.path.exists, c_paths))
# or if annotation or force is specified
annotate = "--annotate" in sys.argv
force = "--force" in sys.argv or annotate

if need_cython or force or annotate:
    try:
        from Cython.Build import cythonize
        from Cython.Compiler import Options
    except ImportError:
        print("Please install Cython", file=sys.stderr)
        exit(1)
    Options.annotate = annotate
    Options.docstrings = True
    Options.embed_pos_in_docstring = True
    Options.warning_errors = True
    hash_indexers = Extension(
        "finalfusion.subword.hash_indexers",
        ["src/finalfusion/subword/hash_indexers.pyx", "src/fnv/hash_64a.c"],
        include_dirs=["src/fnv/", "src/include"])
    ngrams = Extension("finalfusion.subword.ngrams",
                       ["src/finalfusion/subword/ngrams.pyx"])
    explicit_indexer = Extension(
        "finalfusion.subword.explicit_indexer",
        ["src/finalfusion/subword/explicit_indexer.pyx"])
    extensions = cythonize([hash_indexers, ngrams, explicit_indexer], force=force)
else:
    # sdist should include the C files so Cython isn't required
    hash_indexers = Extension(
        "finalfusion.subword.hash_indexers",
        ["src/finalfusion/subword/hash_indexers.c", "src/fnv/hash_64a.c"],
        include_dirs=["src/fnv/", "src/include"])
    ngrams = Extension("finalfusion.subword.ngrams",
                       ["src/finalfusion/subword/ngrams.c"])
    explicit_indexer = Extension(
        "finalfusion.subword.explicit_indexer",
        ["src/finalfusion/subword/explicit_indexer.c"])
    extensions = [hash_indexers, ngrams, explicit_indexer]

install_requires = ["numpy", "toml"]
if sys.version_info.major == 3 and sys.version_info.minor == 6:
    install_requires.append("dataclasses")

setup(name='finalfusion',
      author="Sebastian Pütz <seb.puetz@gmail.com>, Daniël de Kok <me@danieldk.eu>",
      classifiers=[
          "Programming Language :: Python :: 3",
          "Operating System :: OS Independent",
          "Topic :: Text Processing :: Linguistic",
      ],
      cmdclass={'build_ext': cython_build_ext},
      description="Finalfusion in Python",
      ext_modules=extensions,
      install_requires=install_requires,
      keywords='embeddings word2vec finalfusion finalfrontier fasttext glove',
      license='BlueOak-1.0.0',
      long_description=long_description,
      long_description_content_type='text/markdown',
      packages=find_packages('src'),
      include_package_data=True,
      package_dir={'': 'src'},
      package_data={'finalfusion': ['py.typed', '*.pyi', '*.h', '*.c']},
      url="https://github.com/finalfusion/finalfusion-python",
      project_urls={
          "Documentation": "https://finalfusion-python.readthedocs.io/en/0.7.1",
          "Finalfusion": "https://finalfusion.github.io",
      },
      entry_points=dict(console_scripts=[
          'ffp-convert=finalfusion.scripts.convert:main',
          'ffp-bucket-to-explicit=finalfusion.scripts.bucket_to_explicit:main',
          'ffp-similar=finalfusion.scripts.similar:main',
          'ffp-analogy=finalfusion.scripts.analogy:main',
      ]),
      version="0.7.1"
      )
