from setuptools import setup
from setuptools_rust import Binding, RustExtension

setup(
    name="finalfusion",
    version="0.6.0",
    rust_extensions=[RustExtension("finalfusion.finalfusion", binding=Binding.PyO3)],
    packages=["finalfusion"],
    # rust extensions are not zip safe, just like C-extensions.
    zip_safe=False,
)
