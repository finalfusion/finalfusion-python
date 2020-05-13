from setuptools import find_packages, setup

setup(
    name='finalfusion',
    author="Sebastian Pütz",
    author_email="seb.puetz@gmail.com",
    classifiers=[
        "Programming Language :: Python :: 3",
        "Operating System :: OS Independent",
        "Topic :: Text Processing :: Linguistic",
    ],
    description="Interface to finalfusion embeddings",
    install_requires=["numpy", "toml"],
    license='BlueOak-1.0.0',
    packages=find_packages('src'),
    package_dir={'': 'src'},
    package_data={'': ['py.typed']},
    url="https://github.com/finalfusion/ffp"
)
