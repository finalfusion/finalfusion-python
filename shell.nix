{
  pkgs ? import <nixpkgs> {}
, python ? pkgs.python3
}:

with pkgs;

mkShell rec {
  venvDir = "./.venv";

  buildInputs = with python3.pkgs; [
    cython
    numpy
    pytest
    toml
    venvShellHook
  ];

  postShellHook = ''
    # Ensure use of the venv Python interpreter.
    alias pytest="${venvDir}/bin/python -m pytest"
   
    # Install ourselves in the venv. 
    pip install -e .
  '';
}
