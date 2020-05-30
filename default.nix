{
  pkgs ? import <nixpkgs> {}
, python ? pkgs.python3
}:

with python.pkgs;

buildPythonPackage {
  pname = "finalfusion";
  version = "0.7.0-git";

  src = pkgs.nix-gitignore.gitignoreSource [ ".git/" "*.nix" "result*" ] ./.;

  nativeBuildInputs = [
    cython
  ];

  propagatedBuildInputs = [
    numpy
    toml
  ];

  checkInputs = [
    pytest
  ];

   checkPhase = ''
    pytest

    patchShebangs tests/conversion_integration.sh
    export PATH=$PATH:$out/bin
    tests/conversion_integration.sh
  '';
}
