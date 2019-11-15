{
  callPackage
, stdenv

, defaultCrateOverrides
, nix-gitignore

, darwin
, python3Packages
, pkgconfig

, releaseBuild ? true
}:

let
  rustNightly = callPackage ./nix/rust-nightly.nix {};
  cargo_nix = callPackage ./nix/Cargo.nix {};
in cargo_nix.rootCrate.build.override {
  release = releaseBuild;
  rust = rustNightly;

  crateOverrides = defaultCrateOverrides // {
    finalfusion-python = attr: rec {
      pname = "finalfusion-python";
      name = "${pname}-${attr.version}";

      type = [ "cdylib" ];

      src = nix-gitignore.gitignoreSource [ ".git/" "*.nix" "/nix" ] ./.;

      buildInputs = stdenv.lib.optional stdenv.isDarwin darwin.Security;

      installCheckInputs = [ python3Packages.pytest ];

      propagatedBuildInputs = [ python3Packages.numpy ];

      doInstallCheck = true;

      installPhase = let
        sitePackages = python3Packages.python.sitePackages;
        sharedLibrary = stdenv.hostPlatform.extensions.sharedLibrary;
      in ''
        mkdir -p "$out/${sitePackages}"
        cp target/lib/libfinalfusion_python*${sharedLibrary} \
          "$out/${sitePackages}/finalfusion.so"
        export PYTHONPATH="$out/${sitePackages}:$PYTHONPATH"
      '';

      installCheckPhase = ''
        pytest
      '';

      meta = with stdenv.lib; {
        description = "Python module for finalfusion embeddings";
        license = licenses.asl20;
        platforms = platforms.all;
      };
    };

    pyo3 = attr: {
      buildInputs = [ python3Packages.python ];
    };
  };
}
