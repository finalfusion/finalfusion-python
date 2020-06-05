{
  pkgs ? import <nixpkgs> {}
, python ? pkgs.python3
}:

with python.pkgs;

buildPythonPackage {
  pname = "finalfusion";
  version = "0.7.0-git";
  format = "pyproject";

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

    patchShebangs tests/integration
    export PATH=$PATH:$out/bin
    tests/integration/all.sh
  '';

  # Remove when nixpkgs#89607 is merged/fixed.
  shellHook = ''
    runHook preShellHook

    tmp_path=$(mktemp -d)
    export PATH="$tmp_path/bin:$PATH"
    export PYTHONPATH="$tmp_path/${python.sitePackages}:$PYTHONPATH"
    mkdir -p "$tmp_path/${python.sitePackages}"
    ${python.pythonForBuild.interpreter} -m pip install -e . \
      --prefix "$tmp_path" --no-build-isolation >&2

    runHook postShellHook
  '';
}
