with import <nixpkgs> {};
let
  mozillaOverlay = fetchFromGitHub {
    owner = "mozilla";
    repo = "nixpkgs-mozilla";
    rev = "9f35c4b09fd44a77227e79ff0c1b4b6a69dff533";
    sha256 = "18h0nvh55b5an4gmlgfbvwbyqj91bklf1zymis6lbdh75571qaz0";
  };
  rustNightly =
    with import "${mozillaOverlay.out}/rust-overlay.nix" pkgs pkgs;
    (rustChannelOf { date = "2019-02-07"; channel = "nightly"; }).rust;
in stdenv.mkDerivation rec {
  name = "toponn-env";
  env = buildEnv { name = name; paths = buildInputs; };

  nativeBuildInputs = [
    pkgconfig
    pyo3-pack
    python3
    rustNightly
  ];

  propagatedBuildInputs = [
    python3Packages.numpy
  ];

  buildInputs = [
    curl
    libtensorflow
    openssl
  ] ++ lib.optional stdenv.isDarwin darwin.apple_sdk.frameworks.Security;

  shellHook = ''
    ${python3}/bin/python -m venv venv
    source venv/bin/activate
  '';
}
