{ lib, buildRustCrate, buildRustCrateHelpers }:
with buildRustCrateHelpers;
let inherit (lib.lists) fold;
    inherit (lib.attrsets) recursiveUpdate;
in
rec {

# aho-corasick-0.7.6

  crates.aho_corasick."0.7.6" = deps: { features?(features_."aho_corasick"."0.7.6" deps {}) }: buildRustCrate {
    crateName = "aho-corasick";
    version = "0.7.6";
    description = "Fast multiple substring searching.";
    homepage = "https://github.com/BurntSushi/aho-corasick";
    authors = [ "Andrew Gallant <jamslam@gmail.com>" ];
    sha256 = "1srdggg7iawz7rfyb79qfnz6vmzkgl6g6gabyd9ad6pbx7zzj8gz";
    libName = "aho_corasick";
    dependencies = mapFeatures features ([
      (crates."memchr"."${deps."aho_corasick"."0.7.6"."memchr"}" deps)
    ]);
    features = mkFeatures (features."aho_corasick"."0.7.6" or {});
  };
  features_."aho_corasick"."0.7.6" = deps: f: updateFeatures f (rec {
    aho_corasick = fold recursiveUpdate {} [
      { "0.7.6"."std" =
        (f.aho_corasick."0.7.6"."std" or false) ||
        (f.aho_corasick."0.7.6"."default" or false) ||
        (aho_corasick."0.7.6"."default" or false); }
      { "0.7.6".default = (f.aho_corasick."0.7.6".default or true); }
    ];
    memchr = fold recursiveUpdate {} [
      { "${deps.aho_corasick."0.7.6".memchr}"."use_std" =
        (f.memchr."${deps.aho_corasick."0.7.6".memchr}"."use_std" or false) ||
        (aho_corasick."0.7.6"."std" or false) ||
        (f."aho_corasick"."0.7.6"."std" or false); }
      { "${deps.aho_corasick."0.7.6".memchr}".default = (f.memchr."${deps.aho_corasick."0.7.6".memchr}".default or false); }
    ];
  }) [
    (if deps."aho_corasick"."0.7.6" ? "memchr" then features_.memchr."${deps."aho_corasick"."0.7.6"."memchr" or ""}" deps else {})
  ];


# end
# arrayvec-0.4.11

  crates.arrayvec."0.4.11" = deps: { features?(features_."arrayvec"."0.4.11" deps {}) }: buildRustCrate {
    crateName = "arrayvec";
    version = "0.4.11";
    description = "A vector with fixed capacity, backed by an array (it can be stored on the stack too). Implements fixed capacity ArrayVec and ArrayString.";
    authors = [ "bluss" ];
    sha256 = "1bd08rakkyr9jlf538cs80s3ly464ni3afr63zlw860ndar1zfmv";
    dependencies = mapFeatures features ([
      (crates."nodrop"."${deps."arrayvec"."0.4.11"."nodrop"}" deps)
    ]);
    features = mkFeatures (features."arrayvec"."0.4.11" or {});
  };
  features_."arrayvec"."0.4.11" = deps: f: updateFeatures f (rec {
    arrayvec = fold recursiveUpdate {} [
      { "0.4.11"."serde" =
        (f.arrayvec."0.4.11"."serde" or false) ||
        (f.arrayvec."0.4.11"."serde-1" or false) ||
        (arrayvec."0.4.11"."serde-1" or false); }
      { "0.4.11"."std" =
        (f.arrayvec."0.4.11"."std" or false) ||
        (f.arrayvec."0.4.11"."default" or false) ||
        (arrayvec."0.4.11"."default" or false); }
      { "0.4.11".default = (f.arrayvec."0.4.11".default or true); }
    ];
    nodrop."${deps.arrayvec."0.4.11".nodrop}".default = (f.nodrop."${deps.arrayvec."0.4.11".nodrop}".default or false);
  }) [
    (if deps."arrayvec"."0.4.11" ? "nodrop" then features_.nodrop."${deps."arrayvec"."0.4.11"."nodrop" or ""}" deps else {})
  ];


# end
# autocfg-0.1.5

  crates.autocfg."0.1.5" = deps: { features?(features_."autocfg"."0.1.5" deps {}) }: buildRustCrate {
    crateName = "autocfg";
    version = "0.1.5";
    description = "Automatic cfg for Rust compiler features";
    authors = [ "Josh Stone <cuviper@gmail.com>" ];
    sha256 = "1f3bj604fyr4xh08r357hs3hpdzapiqgccvmj1jpi953ffqrp09a";
  };
  features_."autocfg"."0.1.5" = deps: f: updateFeatures f (rec {
    autocfg."0.1.5".default = (f.autocfg."0.1.5".default or true);
  }) [];


# end
# backtrace-0.3.33

  crates.backtrace."0.3.33" = deps: { features?(features_."backtrace"."0.3.33" deps {}) }: buildRustCrate {
    crateName = "backtrace";
    version = "0.3.33";
    description = "A library to acquire a stack trace (backtrace) at runtime in a Rust program.
";
    homepage = "https://github.com/rust-lang/backtrace-rs";
    authors = [ "The Rust Project Developers" ];
    edition = "2018";
    sha256 = "1fkzblhr16hix22sdb22n41l98lrqch86zzpvralh1n83q8qjw98";
    dependencies = mapFeatures features ([
      (crates."cfg_if"."${deps."backtrace"."0.3.33"."cfg_if"}" deps)
      (crates."libc"."${deps."backtrace"."0.3.33"."libc"}" deps)
      (crates."rustc_demangle"."${deps."backtrace"."0.3.33"."rustc_demangle"}" deps)
    ]
      ++ (if features.backtrace."0.3.33".backtrace-sys or false then [ (crates.backtrace_sys."${deps."backtrace"."0.3.33".backtrace_sys}" deps) ] else []))
      ++ (if !(kernel == "darwin" || kernel == "windows") then mapFeatures features ([
]) else [])
      ++ (if kernel == "darwin" then mapFeatures features ([
]) else [])
      ++ (if kernel == "windows" then mapFeatures features ([
]) else []);
    features = mkFeatures (features."backtrace"."0.3.33" or {});
  };
  features_."backtrace"."0.3.33" = deps: f: updateFeatures f (rec {
    backtrace = fold recursiveUpdate {} [
      { "0.3.33"."addr2line" =
        (f.backtrace."0.3.33"."addr2line" or false) ||
        (f.backtrace."0.3.33"."gimli-symbolize" or false) ||
        (backtrace."0.3.33"."gimli-symbolize" or false); }
      { "0.3.33"."backtrace-sys" =
        (f.backtrace."0.3.33"."backtrace-sys" or false) ||
        (f.backtrace."0.3.33"."libbacktrace" or false) ||
        (backtrace."0.3.33"."libbacktrace" or false); }
      { "0.3.33"."compiler_builtins" =
        (f.backtrace."0.3.33"."compiler_builtins" or false) ||
        (f.backtrace."0.3.33"."rustc-dep-of-std" or false) ||
        (backtrace."0.3.33"."rustc-dep-of-std" or false); }
      { "0.3.33"."core" =
        (f.backtrace."0.3.33"."core" or false) ||
        (f.backtrace."0.3.33"."rustc-dep-of-std" or false) ||
        (backtrace."0.3.33"."rustc-dep-of-std" or false); }
      { "0.3.33"."dbghelp" =
        (f.backtrace."0.3.33"."dbghelp" or false) ||
        (f.backtrace."0.3.33"."default" or false) ||
        (backtrace."0.3.33"."default" or false); }
      { "0.3.33"."dladdr" =
        (f.backtrace."0.3.33"."dladdr" or false) ||
        (f.backtrace."0.3.33"."default" or false) ||
        (backtrace."0.3.33"."default" or false); }
      { "0.3.33"."findshlibs" =
        (f.backtrace."0.3.33"."findshlibs" or false) ||
        (f.backtrace."0.3.33"."gimli-symbolize" or false) ||
        (backtrace."0.3.33"."gimli-symbolize" or false); }
      { "0.3.33"."goblin" =
        (f.backtrace."0.3.33"."goblin" or false) ||
        (f.backtrace."0.3.33"."gimli-symbolize" or false) ||
        (backtrace."0.3.33"."gimli-symbolize" or false); }
      { "0.3.33"."libbacktrace" =
        (f.backtrace."0.3.33"."libbacktrace" or false) ||
        (f.backtrace."0.3.33"."default" or false) ||
        (backtrace."0.3.33"."default" or false); }
      { "0.3.33"."libunwind" =
        (f.backtrace."0.3.33"."libunwind" or false) ||
        (f.backtrace."0.3.33"."default" or false) ||
        (backtrace."0.3.33"."default" or false); }
      { "0.3.33"."memmap" =
        (f.backtrace."0.3.33"."memmap" or false) ||
        (f.backtrace."0.3.33"."gimli-symbolize" or false) ||
        (backtrace."0.3.33"."gimli-symbolize" or false); }
      { "0.3.33"."rustc-serialize" =
        (f.backtrace."0.3.33"."rustc-serialize" or false) ||
        (f.backtrace."0.3.33"."serialize-rustc" or false) ||
        (backtrace."0.3.33"."serialize-rustc" or false); }
      { "0.3.33"."serde" =
        (f.backtrace."0.3.33"."serde" or false) ||
        (f.backtrace."0.3.33"."serialize-serde" or false) ||
        (backtrace."0.3.33"."serialize-serde" or false); }
      { "0.3.33"."std" =
        (f.backtrace."0.3.33"."std" or false) ||
        (f.backtrace."0.3.33"."default" or false) ||
        (backtrace."0.3.33"."default" or false); }
      { "0.3.33".default = (f.backtrace."0.3.33".default or true); }
    ];
    backtrace_sys."${deps.backtrace."0.3.33".backtrace_sys}"."rustc-dep-of-std" =
        (f.backtrace_sys."${deps.backtrace."0.3.33".backtrace_sys}"."rustc-dep-of-std" or false) ||
        (backtrace."0.3.33"."rustc-dep-of-std" or false) ||
        (f."backtrace"."0.3.33"."rustc-dep-of-std" or false);
    cfg_if = fold recursiveUpdate {} [
      { "${deps.backtrace."0.3.33".cfg_if}"."rustc-dep-of-std" =
        (f.cfg_if."${deps.backtrace."0.3.33".cfg_if}"."rustc-dep-of-std" or false) ||
        (backtrace."0.3.33"."rustc-dep-of-std" or false) ||
        (f."backtrace"."0.3.33"."rustc-dep-of-std" or false); }
      { "${deps.backtrace."0.3.33".cfg_if}".default = true; }
    ];
    libc = fold recursiveUpdate {} [
      { "${deps.backtrace."0.3.33".libc}"."rustc-dep-of-std" =
        (f.libc."${deps.backtrace."0.3.33".libc}"."rustc-dep-of-std" or false) ||
        (backtrace."0.3.33"."rustc-dep-of-std" or false) ||
        (f."backtrace"."0.3.33"."rustc-dep-of-std" or false); }
      { "${deps.backtrace."0.3.33".libc}".default = (f.libc."${deps.backtrace."0.3.33".libc}".default or false); }
    ];
    rustc_demangle = fold recursiveUpdate {} [
      { "${deps.backtrace."0.3.33".rustc_demangle}"."rustc-dep-of-std" =
        (f.rustc_demangle."${deps.backtrace."0.3.33".rustc_demangle}"."rustc-dep-of-std" or false) ||
        (backtrace."0.3.33"."rustc-dep-of-std" or false) ||
        (f."backtrace"."0.3.33"."rustc-dep-of-std" or false); }
      { "${deps.backtrace."0.3.33".rustc_demangle}".default = true; }
    ];
  }) [
    (f: if deps."backtrace"."0.3.33" ? "backtrace_sys" then recursiveUpdate f { backtrace_sys."${deps."backtrace"."0.3.33"."backtrace_sys"}"."default" = true; } else f)
    (if deps."backtrace"."0.3.33" ? "backtrace_sys" then features_.backtrace_sys."${deps."backtrace"."0.3.33"."backtrace_sys" or ""}" deps else {})
    (if deps."backtrace"."0.3.33" ? "cfg_if" then features_.cfg_if."${deps."backtrace"."0.3.33"."cfg_if" or ""}" deps else {})
    (if deps."backtrace"."0.3.33" ? "libc" then features_.libc."${deps."backtrace"."0.3.33"."libc" or ""}" deps else {})
    (if deps."backtrace"."0.3.33" ? "rustc_demangle" then features_.rustc_demangle."${deps."backtrace"."0.3.33"."rustc_demangle" or ""}" deps else {})
  ];


# end
# backtrace-sys-0.1.31

  crates.backtrace_sys."0.1.31" = deps: { features?(features_."backtrace_sys"."0.1.31" deps {}) }: buildRustCrate {
    crateName = "backtrace-sys";
    version = "0.1.31";
    description = "Bindings to the libbacktrace gcc library
";
    homepage = "https://github.com/alexcrichton/backtrace-rs";
    authors = [ "Alex Crichton <alex@alexcrichton.com>" ];
    sha256 = "1gv41cypl4y5r32za4gx2fks43d76sp1r3yb5524i4gs50lrkypv";
    build = "build.rs";
    dependencies = mapFeatures features ([
      (crates."libc"."${deps."backtrace_sys"."0.1.31"."libc"}" deps)
    ]);

    buildDependencies = mapFeatures features ([
      (crates."cc"."${deps."backtrace_sys"."0.1.31"."cc"}" deps)
    ]);
    features = mkFeatures (features."backtrace_sys"."0.1.31" or {});
  };
  features_."backtrace_sys"."0.1.31" = deps: f: updateFeatures f (rec {
    backtrace_sys = fold recursiveUpdate {} [
      { "0.1.31"."compiler_builtins" =
        (f.backtrace_sys."0.1.31"."compiler_builtins" or false) ||
        (f.backtrace_sys."0.1.31"."rustc-dep-of-std" or false) ||
        (backtrace_sys."0.1.31"."rustc-dep-of-std" or false); }
      { "0.1.31"."core" =
        (f.backtrace_sys."0.1.31"."core" or false) ||
        (f.backtrace_sys."0.1.31"."rustc-dep-of-std" or false) ||
        (backtrace_sys."0.1.31"."rustc-dep-of-std" or false); }
      { "0.1.31".default = (f.backtrace_sys."0.1.31".default or true); }
    ];
    cc."${deps.backtrace_sys."0.1.31".cc}".default = true;
    libc."${deps.backtrace_sys."0.1.31".libc}".default = (f.libc."${deps.backtrace_sys."0.1.31".libc}".default or false);
  }) [
    (if deps."backtrace_sys"."0.1.31" ? "libc" then features_.libc."${deps."backtrace_sys"."0.1.31"."libc" or ""}" deps else {})
    (if deps."backtrace_sys"."0.1.31" ? "cc" then features_.cc."${deps."backtrace_sys"."0.1.31"."cc" or ""}" deps else {})
  ];


# end
# bitflags-1.1.0

  crates.bitflags."1.1.0" = deps: { features?(features_."bitflags"."1.1.0" deps {}) }: buildRustCrate {
    crateName = "bitflags";
    version = "1.1.0";
    description = "A macro to generate structures which behave like bitflags.
";
    homepage = "https://github.com/bitflags/bitflags";
    authors = [ "The Rust Project Developers" ];
    sha256 = "1iwa4jrqcf4lnbwl562a3lx3r0jkh1j88b219bsqvbm4sni67dyv";
    build = "build.rs";
    features = mkFeatures (features."bitflags"."1.1.0" or {});
  };
  features_."bitflags"."1.1.0" = deps: f: updateFeatures f (rec {
    bitflags."1.1.0".default = (f.bitflags."1.1.0".default or true);
  }) [];


# end
# byteorder-1.3.2

  crates.byteorder."1.3.2" = deps: { features?(features_."byteorder"."1.3.2" deps {}) }: buildRustCrate {
    crateName = "byteorder";
    version = "1.3.2";
    description = "Library for reading/writing numbers in big-endian and little-endian.";
    homepage = "https://github.com/BurntSushi/byteorder";
    authors = [ "Andrew Gallant <jamslam@gmail.com>" ];
    sha256 = "099fxwc79ncpcl8dgg9hql8gznz11a3sjs7pai0mg6w8r05khvdx";
    build = "build.rs";
    features = mkFeatures (features."byteorder"."1.3.2" or {});
  };
  features_."byteorder"."1.3.2" = deps: f: updateFeatures f (rec {
    byteorder = fold recursiveUpdate {} [
      { "1.3.2"."std" =
        (f.byteorder."1.3.2"."std" or false) ||
        (f.byteorder."1.3.2"."default" or false) ||
        (byteorder."1.3.2"."default" or false); }
      { "1.3.2".default = (f.byteorder."1.3.2".default or true); }
    ];
  }) [];


# end
# cc-1.0.38

  crates.cc."1.0.38" = deps: { features?(features_."cc"."1.0.38" deps {}) }: buildRustCrate {
    crateName = "cc";
    version = "1.0.38";
    description = "A build-time dependency for Cargo build scripts to assist in invoking the native
C compiler to compile native C code into a static archive to be linked into Rust
code.
";
    homepage = "https://github.com/alexcrichton/cc-rs";
    authors = [ "Alex Crichton <alex@alexcrichton.com>" ];
    sha256 = "17zc9i3mp8jjnrz20ah4inpz2ihmjxl93iswvzm5rv4grk60pzn4";
    dependencies = mapFeatures features ([
]);
    features = mkFeatures (features."cc"."1.0.38" or {});
  };
  features_."cc"."1.0.38" = deps: f: updateFeatures f (rec {
    cc = fold recursiveUpdate {} [
      { "1.0.38"."rayon" =
        (f.cc."1.0.38"."rayon" or false) ||
        (f.cc."1.0.38"."parallel" or false) ||
        (cc."1.0.38"."parallel" or false); }
      { "1.0.38".default = (f.cc."1.0.38".default or true); }
    ];
  }) [];


# end
# cfg-if-0.1.9

  crates.cfg_if."0.1.9" = deps: { features?(features_."cfg_if"."0.1.9" deps {}) }: buildRustCrate {
    crateName = "cfg-if";
    version = "0.1.9";
    description = "A macro to ergonomically define an item depending on a large number of #[cfg]
parameters. Structured like an if-else chain, the first matching branch is the
item that gets emitted.
";
    homepage = "https://github.com/alexcrichton/cfg-if";
    authors = [ "Alex Crichton <alex@alexcrichton.com>" ];
    sha256 = "13g9p2mc5b2b5wn716fwvilzib376ycpkgk868yxfp16jzix57p7";
  };
  features_."cfg_if"."0.1.9" = deps: f: updateFeatures f (rec {
    cfg_if."0.1.9".default = (f.cfg_if."0.1.9".default or true);
  }) [];


# end
# cloudabi-0.0.3

  crates.cloudabi."0.0.3" = deps: { features?(features_."cloudabi"."0.0.3" deps {}) }: buildRustCrate {
    crateName = "cloudabi";
    version = "0.0.3";
    description = "Low level interface to CloudABI. Contains all syscalls and related types.";
    homepage = "https://nuxi.nl/cloudabi/";
    authors = [ "Nuxi (https://nuxi.nl/) and contributors" ];
    sha256 = "1z9lby5sr6vslfd14d6igk03s7awf91mxpsfmsp3prxbxlk0x7h5";
    libPath = "cloudabi.rs";
    dependencies = mapFeatures features ([
    ]
      ++ (if features.cloudabi."0.0.3".bitflags or false then [ (crates.bitflags."${deps."cloudabi"."0.0.3".bitflags}" deps) ] else []));
    features = mkFeatures (features."cloudabi"."0.0.3" or {});
  };
  features_."cloudabi"."0.0.3" = deps: f: updateFeatures f (rec {
    cloudabi = fold recursiveUpdate {} [
      { "0.0.3"."bitflags" =
        (f.cloudabi."0.0.3"."bitflags" or false) ||
        (f.cloudabi."0.0.3"."default" or false) ||
        (cloudabi."0.0.3"."default" or false); }
      { "0.0.3".default = (f.cloudabi."0.0.3".default or true); }
    ];
  }) [
    (f: if deps."cloudabi"."0.0.3" ? "bitflags" then recursiveUpdate f { bitflags."${deps."cloudabi"."0.0.3"."bitflags"}"."default" = true; } else f)
    (if deps."cloudabi"."0.0.3" ? "bitflags" then features_.bitflags."${deps."cloudabi"."0.0.3"."bitflags" or ""}" deps else {})
  ];


# end
# crossbeam-deque-0.6.3

  crates.crossbeam_deque."0.6.3" = deps: { features?(features_."crossbeam_deque"."0.6.3" deps {}) }: buildRustCrate {
    crateName = "crossbeam-deque";
    version = "0.6.3";
    description = "Concurrent work-stealing deque";
    homepage = "https://github.com/crossbeam-rs/crossbeam";
    authors = [ "The Crossbeam Project Developers" ];
    sha256 = "07dahkh6rc09nzg7054rnmxhni263pi9arcyjyy822kg59c0lfz8";
    dependencies = mapFeatures features ([
      (crates."crossbeam_epoch"."${deps."crossbeam_deque"."0.6.3"."crossbeam_epoch"}" deps)
      (crates."crossbeam_utils"."${deps."crossbeam_deque"."0.6.3"."crossbeam_utils"}" deps)
    ]);
  };
  features_."crossbeam_deque"."0.6.3" = deps: f: updateFeatures f (rec {
    crossbeam_deque."0.6.3".default = (f.crossbeam_deque."0.6.3".default or true);
    crossbeam_epoch."${deps.crossbeam_deque."0.6.3".crossbeam_epoch}".default = true;
    crossbeam_utils."${deps.crossbeam_deque."0.6.3".crossbeam_utils}".default = true;
  }) [
    (if deps."crossbeam_deque"."0.6.3" ? "crossbeam_epoch" then features_.crossbeam_epoch."${deps."crossbeam_deque"."0.6.3"."crossbeam_epoch" or ""}" deps else {})
    (if deps."crossbeam_deque"."0.6.3" ? "crossbeam_utils" then features_.crossbeam_utils."${deps."crossbeam_deque"."0.6.3"."crossbeam_utils" or ""}" deps else {})
  ];


# end
# crossbeam-epoch-0.7.1

  crates.crossbeam_epoch."0.7.1" = deps: { features?(features_."crossbeam_epoch"."0.7.1" deps {}) }: buildRustCrate {
    crateName = "crossbeam-epoch";
    version = "0.7.1";
    description = "Epoch-based garbage collection";
    homepage = "https://github.com/crossbeam-rs/crossbeam/tree/master/crossbeam-epoch";
    authors = [ "The Crossbeam Project Developers" ];
    sha256 = "1n2p8rqsg0g8dws6kvjgi5jsbnd42l45dklnzc8vihjcxa6712bg";
    dependencies = mapFeatures features ([
      (crates."arrayvec"."${deps."crossbeam_epoch"."0.7.1"."arrayvec"}" deps)
      (crates."cfg_if"."${deps."crossbeam_epoch"."0.7.1"."cfg_if"}" deps)
      (crates."crossbeam_utils"."${deps."crossbeam_epoch"."0.7.1"."crossbeam_utils"}" deps)
      (crates."memoffset"."${deps."crossbeam_epoch"."0.7.1"."memoffset"}" deps)
      (crates."scopeguard"."${deps."crossbeam_epoch"."0.7.1"."scopeguard"}" deps)
    ]
      ++ (if features.crossbeam_epoch."0.7.1".lazy_static or false then [ (crates.lazy_static."${deps."crossbeam_epoch"."0.7.1".lazy_static}" deps) ] else []));
    features = mkFeatures (features."crossbeam_epoch"."0.7.1" or {});
  };
  features_."crossbeam_epoch"."0.7.1" = deps: f: updateFeatures f (rec {
    arrayvec = fold recursiveUpdate {} [
      { "${deps.crossbeam_epoch."0.7.1".arrayvec}"."use_union" =
        (f.arrayvec."${deps.crossbeam_epoch."0.7.1".arrayvec}"."use_union" or false) ||
        (crossbeam_epoch."0.7.1"."nightly" or false) ||
        (f."crossbeam_epoch"."0.7.1"."nightly" or false); }
      { "${deps.crossbeam_epoch."0.7.1".arrayvec}".default = (f.arrayvec."${deps.crossbeam_epoch."0.7.1".arrayvec}".default or false); }
    ];
    cfg_if."${deps.crossbeam_epoch."0.7.1".cfg_if}".default = true;
    crossbeam_epoch = fold recursiveUpdate {} [
      { "0.7.1"."lazy_static" =
        (f.crossbeam_epoch."0.7.1"."lazy_static" or false) ||
        (f.crossbeam_epoch."0.7.1"."std" or false) ||
        (crossbeam_epoch."0.7.1"."std" or false); }
      { "0.7.1"."std" =
        (f.crossbeam_epoch."0.7.1"."std" or false) ||
        (f.crossbeam_epoch."0.7.1"."default" or false) ||
        (crossbeam_epoch."0.7.1"."default" or false); }
      { "0.7.1".default = (f.crossbeam_epoch."0.7.1".default or true); }
    ];
    crossbeam_utils = fold recursiveUpdate {} [
      { "${deps.crossbeam_epoch."0.7.1".crossbeam_utils}"."nightly" =
        (f.crossbeam_utils."${deps.crossbeam_epoch."0.7.1".crossbeam_utils}"."nightly" or false) ||
        (crossbeam_epoch."0.7.1"."nightly" or false) ||
        (f."crossbeam_epoch"."0.7.1"."nightly" or false); }
      { "${deps.crossbeam_epoch."0.7.1".crossbeam_utils}"."std" =
        (f.crossbeam_utils."${deps.crossbeam_epoch."0.7.1".crossbeam_utils}"."std" or false) ||
        (crossbeam_epoch."0.7.1"."std" or false) ||
        (f."crossbeam_epoch"."0.7.1"."std" or false); }
      { "${deps.crossbeam_epoch."0.7.1".crossbeam_utils}".default = (f.crossbeam_utils."${deps.crossbeam_epoch."0.7.1".crossbeam_utils}".default or false); }
    ];
    memoffset."${deps.crossbeam_epoch."0.7.1".memoffset}".default = true;
    scopeguard."${deps.crossbeam_epoch."0.7.1".scopeguard}".default = (f.scopeguard."${deps.crossbeam_epoch."0.7.1".scopeguard}".default or false);
  }) [
    (f: if deps."crossbeam_epoch"."0.7.1" ? "lazy_static" then recursiveUpdate f { lazy_static."${deps."crossbeam_epoch"."0.7.1"."lazy_static"}"."default" = true; } else f)
    (if deps."crossbeam_epoch"."0.7.1" ? "arrayvec" then features_.arrayvec."${deps."crossbeam_epoch"."0.7.1"."arrayvec" or ""}" deps else {})
    (if deps."crossbeam_epoch"."0.7.1" ? "cfg_if" then features_.cfg_if."${deps."crossbeam_epoch"."0.7.1"."cfg_if" or ""}" deps else {})
    (if deps."crossbeam_epoch"."0.7.1" ? "crossbeam_utils" then features_.crossbeam_utils."${deps."crossbeam_epoch"."0.7.1"."crossbeam_utils" or ""}" deps else {})
    (if deps."crossbeam_epoch"."0.7.1" ? "lazy_static" then features_.lazy_static."${deps."crossbeam_epoch"."0.7.1"."lazy_static" or ""}" deps else {})
    (if deps."crossbeam_epoch"."0.7.1" ? "memoffset" then features_.memoffset."${deps."crossbeam_epoch"."0.7.1"."memoffset" or ""}" deps else {})
    (if deps."crossbeam_epoch"."0.7.1" ? "scopeguard" then features_.scopeguard."${deps."crossbeam_epoch"."0.7.1"."scopeguard" or ""}" deps else {})
  ];


# end
# crossbeam-queue-0.1.2

  crates.crossbeam_queue."0.1.2" = deps: { features?(features_."crossbeam_queue"."0.1.2" deps {}) }: buildRustCrate {
    crateName = "crossbeam-queue";
    version = "0.1.2";
    description = "Concurrent queues";
    homepage = "https://github.com/crossbeam-rs/crossbeam/tree/master/crossbeam-utils";
    authors = [ "The Crossbeam Project Developers" ];
    sha256 = "1hannzr5w6j5061kg5iba4fzi6f2xpqv7bkcspfq17y1i8g0mzjj";
    dependencies = mapFeatures features ([
      (crates."crossbeam_utils"."${deps."crossbeam_queue"."0.1.2"."crossbeam_utils"}" deps)
    ]);
  };
  features_."crossbeam_queue"."0.1.2" = deps: f: updateFeatures f (rec {
    crossbeam_queue."0.1.2".default = (f.crossbeam_queue."0.1.2".default or true);
    crossbeam_utils."${deps.crossbeam_queue."0.1.2".crossbeam_utils}".default = true;
  }) [
    (if deps."crossbeam_queue"."0.1.2" ? "crossbeam_utils" then features_.crossbeam_utils."${deps."crossbeam_queue"."0.1.2"."crossbeam_utils" or ""}" deps else {})
  ];


# end
# crossbeam-utils-0.6.5

  crates.crossbeam_utils."0.6.5" = deps: { features?(features_."crossbeam_utils"."0.6.5" deps {}) }: buildRustCrate {
    crateName = "crossbeam-utils";
    version = "0.6.5";
    description = "Utilities for concurrent programming";
    homepage = "https://github.com/crossbeam-rs/crossbeam/tree/master/crossbeam-utils";
    authors = [ "The Crossbeam Project Developers" ];
    sha256 = "1z7wgcl9d22r2x6769r5945rnwf3jqfrrmb16q7kzk292r1d4rdg";
    dependencies = mapFeatures features ([
      (crates."cfg_if"."${deps."crossbeam_utils"."0.6.5"."cfg_if"}" deps)
    ]
      ++ (if features.crossbeam_utils."0.6.5".lazy_static or false then [ (crates.lazy_static."${deps."crossbeam_utils"."0.6.5".lazy_static}" deps) ] else []));
    features = mkFeatures (features."crossbeam_utils"."0.6.5" or {});
  };
  features_."crossbeam_utils"."0.6.5" = deps: f: updateFeatures f (rec {
    cfg_if."${deps.crossbeam_utils."0.6.5".cfg_if}".default = true;
    crossbeam_utils = fold recursiveUpdate {} [
      { "0.6.5"."lazy_static" =
        (f.crossbeam_utils."0.6.5"."lazy_static" or false) ||
        (f.crossbeam_utils."0.6.5"."std" or false) ||
        (crossbeam_utils."0.6.5"."std" or false); }
      { "0.6.5"."std" =
        (f.crossbeam_utils."0.6.5"."std" or false) ||
        (f.crossbeam_utils."0.6.5"."default" or false) ||
        (crossbeam_utils."0.6.5"."default" or false); }
      { "0.6.5".default = (f.crossbeam_utils."0.6.5".default or true); }
    ];
  }) [
    (f: if deps."crossbeam_utils"."0.6.5" ? "lazy_static" then recursiveUpdate f { lazy_static."${deps."crossbeam_utils"."0.6.5"."lazy_static"}"."default" = true; } else f)
    (if deps."crossbeam_utils"."0.6.5" ? "cfg_if" then features_.cfg_if."${deps."crossbeam_utils"."0.6.5"."cfg_if" or ""}" deps else {})
    (if deps."crossbeam_utils"."0.6.5" ? "lazy_static" then features_.lazy_static."${deps."crossbeam_utils"."0.6.5"."lazy_static" or ""}" deps else {})
  ];


# end
# ctor-0.1.9

  crates.ctor."0.1.9" = deps: { features?(features_."ctor"."0.1.9" deps {}) }: buildRustCrate {
    crateName = "ctor";
    version = "0.1.9";
    description = "__attribute__((constructor)) for Rust";
    authors = [ "Matt Mastracci <matthew@mastracci.com>" ];
    edition = "2018";
    sha256 = "1028s4rx1s1zx291ahfba6gvb85phvhldg27fvcpqxm1qwp3jqc0";
    procMacro = true;
    dependencies = mapFeatures features ([
      (crates."quote"."${deps."ctor"."0.1.9"."quote"}" deps)
      (crates."syn"."${deps."ctor"."0.1.9"."syn"}" deps)
    ]);
  };
  features_."ctor"."0.1.9" = deps: f: updateFeatures f (rec {
    ctor."0.1.9".default = (f.ctor."0.1.9".default or true);
    quote."${deps.ctor."0.1.9".quote}".default = true;
    syn = fold recursiveUpdate {} [
      { "${deps.ctor."0.1.9".syn}"."fold" = true; }
      { "${deps.ctor."0.1.9".syn}"."full" = true; }
      { "${deps.ctor."0.1.9".syn}"."parsing" = true; }
      { "${deps.ctor."0.1.9".syn}"."printing" = true; }
      { "${deps.ctor."0.1.9".syn}"."proc-macro" = true; }
      { "${deps.ctor."0.1.9".syn}".default = (f.syn."${deps.ctor."0.1.9".syn}".default or false); }
    ];
  }) [
    (if deps."ctor"."0.1.9" ? "quote" then features_.quote."${deps."ctor"."0.1.9"."quote" or ""}" deps else {})
    (if deps."ctor"."0.1.9" ? "syn" then features_.syn."${deps."ctor"."0.1.9"."syn" or ""}" deps else {})
  ];


# end
# either-1.5.2

  crates.either."1.5.2" = deps: { features?(features_."either"."1.5.2" deps {}) }: buildRustCrate {
    crateName = "either";
    version = "1.5.2";
    description = "The enum `Either` with variants `Left` and `Right` is a general purpose sum type with two cases.
";
    authors = [ "bluss" ];
    sha256 = "1zqq1057c51f53ga4p9l4dd8ax6md27h1xjrjp2plkvml5iymks5";
    dependencies = mapFeatures features ([
]);
    features = mkFeatures (features."either"."1.5.2" or {});
  };
  features_."either"."1.5.2" = deps: f: updateFeatures f (rec {
    either = fold recursiveUpdate {} [
      { "1.5.2"."use_std" =
        (f.either."1.5.2"."use_std" or false) ||
        (f.either."1.5.2"."default" or false) ||
        (either."1.5.2"."default" or false); }
      { "1.5.2".default = (f.either."1.5.2".default or true); }
    ];
  }) [];


# end
# failure-0.1.5

  crates.failure."0.1.5" = deps: { features?(features_."failure"."0.1.5" deps {}) }: buildRustCrate {
    crateName = "failure";
    version = "0.1.5";
    description = "Experimental error handling abstraction.";
    homepage = "https://rust-lang-nursery.github.io/failure/";
    authors = [ "Without Boats <boats@mozilla.com>" ];
    sha256 = "1msaj1c0fg12dzyf4fhxqlx1gfx41lj2smdjmkc9hkrgajk2g3kx";
    dependencies = mapFeatures features ([
    ]
      ++ (if features.failure."0.1.5".backtrace or false then [ (crates.backtrace."${deps."failure"."0.1.5".backtrace}" deps) ] else [])
      ++ (if features.failure."0.1.5".failure_derive or false then [ (crates.failure_derive."${deps."failure"."0.1.5".failure_derive}" deps) ] else []));
    features = mkFeatures (features."failure"."0.1.5" or {});
  };
  features_."failure"."0.1.5" = deps: f: updateFeatures f (rec {
    failure = fold recursiveUpdate {} [
      { "0.1.5"."backtrace" =
        (f.failure."0.1.5"."backtrace" or false) ||
        (f.failure."0.1.5"."std" or false) ||
        (failure."0.1.5"."std" or false); }
      { "0.1.5"."derive" =
        (f.failure."0.1.5"."derive" or false) ||
        (f.failure."0.1.5"."default" or false) ||
        (failure."0.1.5"."default" or false); }
      { "0.1.5"."failure_derive" =
        (f.failure."0.1.5"."failure_derive" or false) ||
        (f.failure."0.1.5"."derive" or false) ||
        (failure."0.1.5"."derive" or false); }
      { "0.1.5"."std" =
        (f.failure."0.1.5"."std" or false) ||
        (f.failure."0.1.5"."default" or false) ||
        (failure."0.1.5"."default" or false); }
      { "0.1.5".default = (f.failure."0.1.5".default or true); }
    ];
  }) [
    (f: if deps."failure"."0.1.5" ? "backtrace" then recursiveUpdate f { backtrace."${deps."failure"."0.1.5"."backtrace"}"."default" = true; } else f)
    (f: if deps."failure"."0.1.5" ? "failure_derive" then recursiveUpdate f { failure_derive."${deps."failure"."0.1.5"."failure_derive"}"."default" = true; } else f)
    (if deps."failure"."0.1.5" ? "backtrace" then features_.backtrace."${deps."failure"."0.1.5"."backtrace" or ""}" deps else {})
    (if deps."failure"."0.1.5" ? "failure_derive" then features_.failure_derive."${deps."failure"."0.1.5"."failure_derive" or ""}" deps else {})
  ];


# end
# failure_derive-0.1.5

  crates.failure_derive."0.1.5" = deps: { features?(features_."failure_derive"."0.1.5" deps {}) }: buildRustCrate {
    crateName = "failure_derive";
    version = "0.1.5";
    description = "derives for the failure crate";
    homepage = "https://rust-lang-nursery.github.io/failure/";
    authors = [ "Without Boats <woboats@gmail.com>" ];
    sha256 = "1wzk484b87r4qszcvdl2bkniv5ls4r2f2dshz7hmgiv6z4ln12g0";
    procMacro = true;
    build = "build.rs";
    dependencies = mapFeatures features ([
      (crates."proc_macro2"."${deps."failure_derive"."0.1.5"."proc_macro2"}" deps)
      (crates."quote"."${deps."failure_derive"."0.1.5"."quote"}" deps)
      (crates."syn"."${deps."failure_derive"."0.1.5"."syn"}" deps)
      (crates."synstructure"."${deps."failure_derive"."0.1.5"."synstructure"}" deps)
    ]);
    features = mkFeatures (features."failure_derive"."0.1.5" or {});
  };
  features_."failure_derive"."0.1.5" = deps: f: updateFeatures f (rec {
    failure_derive."0.1.5".default = (f.failure_derive."0.1.5".default or true);
    proc_macro2."${deps.failure_derive."0.1.5".proc_macro2}".default = true;
    quote."${deps.failure_derive."0.1.5".quote}".default = true;
    syn."${deps.failure_derive."0.1.5".syn}".default = true;
    synstructure."${deps.failure_derive."0.1.5".synstructure}".default = true;
  }) [
    (if deps."failure_derive"."0.1.5" ? "proc_macro2" then features_.proc_macro2."${deps."failure_derive"."0.1.5"."proc_macro2" or ""}" deps else {})
    (if deps."failure_derive"."0.1.5" ? "quote" then features_.quote."${deps."failure_derive"."0.1.5"."quote" or ""}" deps else {})
    (if deps."failure_derive"."0.1.5" ? "syn" then features_.syn."${deps."failure_derive"."0.1.5"."syn" or ""}" deps else {})
    (if deps."failure_derive"."0.1.5" ? "synstructure" then features_.synstructure."${deps."failure_derive"."0.1.5"."synstructure" or ""}" deps else {})
  ];


# end
# finalfusion-0.9.0

  crates.finalfusion."0.9.0" = deps: { features?(features_."finalfusion"."0.9.0" deps {}) }: buildRustCrate {
    crateName = "finalfusion";
    version = "0.9.0";
    description = "Reader and writer for common word embedding formats";
    homepage = "https://github.com/finalfusion/finalfusion-rust";
    authors = [ "Daniël de Kok <me@danieldk.eu>" ];
    edition = "2018";
    sha256 = "05p31mv12h9168cbi62b6grk7spq6v9g8qr87pxgrhpllz93a2zr";
    dependencies = mapFeatures features ([
      (crates."byteorder"."${deps."finalfusion"."0.9.0"."byteorder"}" deps)
      (crates."fnv"."${deps."finalfusion"."0.9.0"."fnv"}" deps)
      (crates."itertools"."${deps."finalfusion"."0.9.0"."itertools"}" deps)
      (crates."memmap"."${deps."finalfusion"."0.9.0"."memmap"}" deps)
      (crates."ndarray"."${deps."finalfusion"."0.9.0"."ndarray"}" deps)
      (crates."ordered_float"."${deps."finalfusion"."0.9.0"."ordered_float"}" deps)
      (crates."rand"."${deps."finalfusion"."0.9.0"."rand"}" deps)
      (crates."rand_xorshift"."${deps."finalfusion"."0.9.0"."rand_xorshift"}" deps)
      (crates."reductive"."${deps."finalfusion"."0.9.0"."reductive"}" deps)
      (crates."serde"."${deps."finalfusion"."0.9.0"."serde"}" deps)
      (crates."toml"."${deps."finalfusion"."0.9.0"."toml"}" deps)
    ]);
  };
  features_."finalfusion"."0.9.0" = deps: f: updateFeatures f (rec {
    byteorder."${deps.finalfusion."0.9.0".byteorder}".default = true;
    finalfusion."0.9.0".default = (f.finalfusion."0.9.0".default or true);
    fnv."${deps.finalfusion."0.9.0".fnv}".default = true;
    itertools."${deps.finalfusion."0.9.0".itertools}".default = true;
    memmap."${deps.finalfusion."0.9.0".memmap}".default = true;
    ndarray."${deps.finalfusion."0.9.0".ndarray}".default = true;
    ordered_float."${deps.finalfusion."0.9.0".ordered_float}".default = true;
    rand."${deps.finalfusion."0.9.0".rand}".default = true;
    rand_xorshift."${deps.finalfusion."0.9.0".rand_xorshift}".default = true;
    reductive."${deps.finalfusion."0.9.0".reductive}".default = true;
    serde = fold recursiveUpdate {} [
      { "${deps.finalfusion."0.9.0".serde}"."derive" = true; }
      { "${deps.finalfusion."0.9.0".serde}".default = true; }
    ];
    toml."${deps.finalfusion."0.9.0".toml}".default = true;
  }) [
    (if deps."finalfusion"."0.9.0" ? "byteorder" then features_.byteorder."${deps."finalfusion"."0.9.0"."byteorder" or ""}" deps else {})
    (if deps."finalfusion"."0.9.0" ? "fnv" then features_.fnv."${deps."finalfusion"."0.9.0"."fnv" or ""}" deps else {})
    (if deps."finalfusion"."0.9.0" ? "itertools" then features_.itertools."${deps."finalfusion"."0.9.0"."itertools" or ""}" deps else {})
    (if deps."finalfusion"."0.9.0" ? "memmap" then features_.memmap."${deps."finalfusion"."0.9.0"."memmap" or ""}" deps else {})
    (if deps."finalfusion"."0.9.0" ? "ndarray" then features_.ndarray."${deps."finalfusion"."0.9.0"."ndarray" or ""}" deps else {})
    (if deps."finalfusion"."0.9.0" ? "ordered_float" then features_.ordered_float."${deps."finalfusion"."0.9.0"."ordered_float" or ""}" deps else {})
    (if deps."finalfusion"."0.9.0" ? "rand" then features_.rand."${deps."finalfusion"."0.9.0"."rand" or ""}" deps else {})
    (if deps."finalfusion"."0.9.0" ? "rand_xorshift" then features_.rand_xorshift."${deps."finalfusion"."0.9.0"."rand_xorshift" or ""}" deps else {})
    (if deps."finalfusion"."0.9.0" ? "reductive" then features_.reductive."${deps."finalfusion"."0.9.0"."reductive" or ""}" deps else {})
    (if deps."finalfusion"."0.9.0" ? "serde" then features_.serde."${deps."finalfusion"."0.9.0"."serde" or ""}" deps else {})
    (if deps."finalfusion"."0.9.0" ? "toml" then features_.toml."${deps."finalfusion"."0.9.0"."toml" or ""}" deps else {})
  ];


# end
# fnv-1.0.6

  crates.fnv."1.0.6" = deps: { features?(features_."fnv"."1.0.6" deps {}) }: buildRustCrate {
    crateName = "fnv";
    version = "1.0.6";
    description = "Fowler–Noll–Vo hash function";
    authors = [ "Alex Crichton <alex@alexcrichton.com>" ];
    sha256 = "128mlh23y3gg6ag5h8iiqlcbl59smisdzraqy88ldrf75kbw27ip";
    libPath = "lib.rs";
  };
  features_."fnv"."1.0.6" = deps: f: updateFeatures f (rec {
    fnv."1.0.6".default = (f.fnv."1.0.6".default or true);
  }) [];


# end
# fuchsia-cprng-0.1.1

  crates.fuchsia_cprng."0.1.1" = deps: { features?(features_."fuchsia_cprng"."0.1.1" deps {}) }: buildRustCrate {
    crateName = "fuchsia-cprng";
    version = "0.1.1";
    description = "Rust crate for the Fuchsia cryptographically secure pseudorandom number generator";
    authors = [ "Erick Tryzelaar <etryzelaar@google.com>" ];
    edition = "2018";
    sha256 = "07apwv9dj716yjlcj29p94vkqn5zmfh7hlrqvrjx3wzshphc95h9";
  };
  features_."fuchsia_cprng"."0.1.1" = deps: f: updateFeatures f (rec {
    fuchsia_cprng."0.1.1".default = (f.fuchsia_cprng."0.1.1".default or true);
  }) [];


# end
# ghost-0.1.0

  crates.ghost."0.1.0" = deps: { features?(features_."ghost"."0.1.0" deps {}) }: buildRustCrate {
    crateName = "ghost";
    version = "0.1.0";
    description = "Define your own PhantomData";
    authors = [ "David Tolnay <dtolnay@gmail.com>" ];
    edition = "2018";
    sha256 = "03kpnfk7xlkjv18mfvqdprhlq625lfri6l163lhrfma7j9c7i730";
    procMacro = true;
    dependencies = mapFeatures features ([
      (crates."proc_macro2"."${deps."ghost"."0.1.0"."proc_macro2"}" deps)
      (crates."quote"."${deps."ghost"."0.1.0"."quote"}" deps)
      (crates."syn"."${deps."ghost"."0.1.0"."syn"}" deps)
    ]);
  };
  features_."ghost"."0.1.0" = deps: f: updateFeatures f (rec {
    ghost."0.1.0".default = (f.ghost."0.1.0".default or true);
    proc_macro2."${deps.ghost."0.1.0".proc_macro2}".default = true;
    quote."${deps.ghost."0.1.0".quote}".default = true;
    syn."${deps.ghost."0.1.0".syn}".default = true;
  }) [
    (if deps."ghost"."0.1.0" ? "proc_macro2" then features_.proc_macro2."${deps."ghost"."0.1.0"."proc_macro2" or ""}" deps else {})
    (if deps."ghost"."0.1.0" ? "quote" then features_.quote."${deps."ghost"."0.1.0"."quote" or ""}" deps else {})
    (if deps."ghost"."0.1.0" ? "syn" then features_.syn."${deps."ghost"."0.1.0"."syn" or ""}" deps else {})
  ];


# end
# indoc-0.3.4

  crates.indoc."0.3.4" = deps: { features?(features_."indoc"."0.3.4" deps {}) }: buildRustCrate {
    crateName = "indoc";
    version = "0.3.4";
    description = "Indented document literals";
    authors = [ "David Tolnay <dtolnay@gmail.com>" ];
    edition = "2018";
    sha256 = "0jd2axphh5m8yrpj77rijf6pap43ic9wrph68hiz0lckbnn02z3b";
    dependencies = mapFeatures features ([
      (crates."indoc_impl"."${deps."indoc"."0.3.4"."indoc_impl"}" deps)
      (crates."proc_macro_hack"."${deps."indoc"."0.3.4"."proc_macro_hack"}" deps)
    ]);
    features = mkFeatures (features."indoc"."0.3.4" or {});
  };
  features_."indoc"."0.3.4" = deps: f: updateFeatures f (rec {
    indoc."0.3.4".default = (f.indoc."0.3.4".default or true);
    indoc_impl = fold recursiveUpdate {} [
      { "${deps.indoc."0.3.4".indoc_impl}"."unstable" =
        (f.indoc_impl."${deps.indoc."0.3.4".indoc_impl}"."unstable" or false) ||
        (indoc."0.3.4"."unstable" or false) ||
        (f."indoc"."0.3.4"."unstable" or false); }
      { "${deps.indoc."0.3.4".indoc_impl}".default = true; }
    ];
    proc_macro_hack."${deps.indoc."0.3.4".proc_macro_hack}".default = true;
  }) [
    (if deps."indoc"."0.3.4" ? "indoc_impl" then features_.indoc_impl."${deps."indoc"."0.3.4"."indoc_impl" or ""}" deps else {})
    (if deps."indoc"."0.3.4" ? "proc_macro_hack" then features_.proc_macro_hack."${deps."indoc"."0.3.4"."proc_macro_hack" or ""}" deps else {})
  ];


# end
# indoc-impl-0.3.4

  crates.indoc_impl."0.3.4" = deps: { features?(features_."indoc_impl"."0.3.4" deps {}) }: buildRustCrate {
    crateName = "indoc-impl";
    version = "0.3.4";
    description = "Indented document literals";
    authors = [ "David Tolnay <dtolnay@gmail.com>" ];
    edition = "2018";
    sha256 = "1mkjjshsygdd10sn6fyfk3ki4jilygxhza6606s3rcx789nqrdqx";
    procMacro = true;
    dependencies = mapFeatures features ([
      (crates."proc_macro_hack"."${deps."indoc_impl"."0.3.4"."proc_macro_hack"}" deps)
      (crates."proc_macro2"."${deps."indoc_impl"."0.3.4"."proc_macro2"}" deps)
      (crates."quote"."${deps."indoc_impl"."0.3.4"."quote"}" deps)
      (crates."syn"."${deps."indoc_impl"."0.3.4"."syn"}" deps)
      (crates."unindent"."${deps."indoc_impl"."0.3.4"."unindent"}" deps)
    ]);
    features = mkFeatures (features."indoc_impl"."0.3.4" or {});
  };
  features_."indoc_impl"."0.3.4" = deps: f: updateFeatures f (rec {
    indoc_impl."0.3.4".default = (f.indoc_impl."0.3.4".default or true);
    proc_macro2."${deps.indoc_impl."0.3.4".proc_macro2}".default = true;
    proc_macro_hack."${deps.indoc_impl."0.3.4".proc_macro_hack}".default = true;
    quote."${deps.indoc_impl."0.3.4".quote}".default = true;
    syn."${deps.indoc_impl."0.3.4".syn}".default = true;
    unindent."${deps.indoc_impl."0.3.4".unindent}".default = true;
  }) [
    (if deps."indoc_impl"."0.3.4" ? "proc_macro_hack" then features_.proc_macro_hack."${deps."indoc_impl"."0.3.4"."proc_macro_hack" or ""}" deps else {})
    (if deps."indoc_impl"."0.3.4" ? "proc_macro2" then features_.proc_macro2."${deps."indoc_impl"."0.3.4"."proc_macro2" or ""}" deps else {})
    (if deps."indoc_impl"."0.3.4" ? "quote" then features_.quote."${deps."indoc_impl"."0.3.4"."quote" or ""}" deps else {})
    (if deps."indoc_impl"."0.3.4" ? "syn" then features_.syn."${deps."indoc_impl"."0.3.4"."syn" or ""}" deps else {})
    (if deps."indoc_impl"."0.3.4" ? "unindent" then features_.unindent."${deps."indoc_impl"."0.3.4"."unindent" or ""}" deps else {})
  ];


# end
# inventory-0.1.4

  crates.inventory."0.1.4" = deps: { features?(features_."inventory"."0.1.4" deps {}) }: buildRustCrate {
    crateName = "inventory";
    version = "0.1.4";
    description = "Typed distributed plugin registration";
    authors = [ "David Tolnay <dtolnay@gmail.com>" ];
    edition = "2018";
    sha256 = "0a7yndzhxjfkk2baf6zb0ix886lwcsbm45zg05ci272wbjcyz3zh";
    dependencies = mapFeatures features ([
      (crates."ctor"."${deps."inventory"."0.1.4"."ctor"}" deps)
      (crates."ghost"."${deps."inventory"."0.1.4"."ghost"}" deps)
      (crates."inventory_impl"."${deps."inventory"."0.1.4"."inventory_impl"}" deps)
    ]);
  };
  features_."inventory"."0.1.4" = deps: f: updateFeatures f (rec {
    ctor."${deps.inventory."0.1.4".ctor}".default = true;
    ghost."${deps.inventory."0.1.4".ghost}".default = true;
    inventory."0.1.4".default = (f.inventory."0.1.4".default or true);
    inventory_impl."${deps.inventory."0.1.4".inventory_impl}".default = true;
  }) [
    (if deps."inventory"."0.1.4" ? "ctor" then features_.ctor."${deps."inventory"."0.1.4"."ctor" or ""}" deps else {})
    (if deps."inventory"."0.1.4" ? "ghost" then features_.ghost."${deps."inventory"."0.1.4"."ghost" or ""}" deps else {})
    (if deps."inventory"."0.1.4" ? "inventory_impl" then features_.inventory_impl."${deps."inventory"."0.1.4"."inventory_impl" or ""}" deps else {})
  ];


# end
# inventory-impl-0.1.4

  crates.inventory_impl."0.1.4" = deps: { features?(features_."inventory_impl"."0.1.4" deps {}) }: buildRustCrate {
    crateName = "inventory-impl";
    version = "0.1.4";
    description = "Implementation of macros for the `inventory` crate";
    authors = [ "David Tolnay <dtolnay@gmail.com>" ];
    edition = "2018";
    sha256 = "07y47wbk367y207qfw9lx2wypz3wp2247vbq3vmypbapixdpv4c1";
    procMacro = true;
    dependencies = mapFeatures features ([
      (crates."proc_macro2"."${deps."inventory_impl"."0.1.4"."proc_macro2"}" deps)
      (crates."quote"."${deps."inventory_impl"."0.1.4"."quote"}" deps)
      (crates."syn"."${deps."inventory_impl"."0.1.4"."syn"}" deps)
    ]);
  };
  features_."inventory_impl"."0.1.4" = deps: f: updateFeatures f (rec {
    inventory_impl."0.1.4".default = (f.inventory_impl."0.1.4".default or true);
    proc_macro2."${deps.inventory_impl."0.1.4".proc_macro2}".default = true;
    quote."${deps.inventory_impl."0.1.4".quote}".default = true;
    syn."${deps.inventory_impl."0.1.4".syn}".default = true;
  }) [
    (if deps."inventory_impl"."0.1.4" ? "proc_macro2" then features_.proc_macro2."${deps."inventory_impl"."0.1.4"."proc_macro2" or ""}" deps else {})
    (if deps."inventory_impl"."0.1.4" ? "quote" then features_.quote."${deps."inventory_impl"."0.1.4"."quote" or ""}" deps else {})
    (if deps."inventory_impl"."0.1.4" ? "syn" then features_.syn."${deps."inventory_impl"."0.1.4"."syn" or ""}" deps else {})
  ];


# end
# itertools-0.7.11

  crates.itertools."0.7.11" = deps: { features?(features_."itertools"."0.7.11" deps {}) }: buildRustCrate {
    crateName = "itertools";
    version = "0.7.11";
    description = "Extra iterator adaptors, iterator methods, free functions, and macros.";
    authors = [ "bluss" ];
    sha256 = "0gavmkvn2c3cwfwk5zl5p7saiqn4ww227am5ykn6pgfm7c6ppz56";
    dependencies = mapFeatures features ([
      (crates."either"."${deps."itertools"."0.7.11"."either"}" deps)
    ]);
    features = mkFeatures (features."itertools"."0.7.11" or {});
  };
  features_."itertools"."0.7.11" = deps: f: updateFeatures f (rec {
    either."${deps.itertools."0.7.11".either}".default = (f.either."${deps.itertools."0.7.11".either}".default or false);
    itertools = fold recursiveUpdate {} [
      { "0.7.11"."use_std" =
        (f.itertools."0.7.11"."use_std" or false) ||
        (f.itertools."0.7.11"."default" or false) ||
        (itertools."0.7.11"."default" or false); }
      { "0.7.11".default = (f.itertools."0.7.11".default or true); }
    ];
  }) [
    (if deps."itertools"."0.7.11" ? "either" then features_.either."${deps."itertools"."0.7.11"."either" or ""}" deps else {})
  ];


# end
# itertools-0.8.0

  crates.itertools."0.8.0" = deps: { features?(features_."itertools"."0.8.0" deps {}) }: buildRustCrate {
    crateName = "itertools";
    version = "0.8.0";
    description = "Extra iterator adaptors, iterator methods, free functions, and macros.";
    authors = [ "bluss" ];
    sha256 = "0xpz59yf03vyj540i7sqypn2aqfid08c4vzyg0l6rqm08da77n7n";
    dependencies = mapFeatures features ([
      (crates."either"."${deps."itertools"."0.8.0"."either"}" deps)
    ]);
    features = mkFeatures (features."itertools"."0.8.0" or {});
  };
  features_."itertools"."0.8.0" = deps: f: updateFeatures f (rec {
    either."${deps.itertools."0.8.0".either}".default = (f.either."${deps.itertools."0.8.0".either}".default or false);
    itertools = fold recursiveUpdate {} [
      { "0.8.0"."use_std" =
        (f.itertools."0.8.0"."use_std" or false) ||
        (f.itertools."0.8.0"."default" or false) ||
        (itertools."0.8.0"."default" or false); }
      { "0.8.0".default = (f.itertools."0.8.0".default or true); }
    ];
  }) [
    (if deps."itertools"."0.8.0" ? "either" then features_.either."${deps."itertools"."0.8.0"."either" or ""}" deps else {})
  ];


# end
# itoa-0.4.4

  crates.itoa."0.4.4" = deps: { features?(features_."itoa"."0.4.4" deps {}) }: buildRustCrate {
    crateName = "itoa";
    version = "0.4.4";
    description = "Fast functions for printing integer primitives to an io::Write";
    authors = [ "David Tolnay <dtolnay@gmail.com>" ];
    sha256 = "1fqc34xzzl2spfdawxd9awhzl0fwf1y6y4i94l8bq8rfrzd90awl";
    features = mkFeatures (features."itoa"."0.4.4" or {});
  };
  features_."itoa"."0.4.4" = deps: f: updateFeatures f (rec {
    itoa = fold recursiveUpdate {} [
      { "0.4.4"."std" =
        (f.itoa."0.4.4"."std" or false) ||
        (f.itoa."0.4.4"."default" or false) ||
        (itoa."0.4.4"."default" or false); }
      { "0.4.4".default = (f.itoa."0.4.4".default or true); }
    ];
  }) [];


# end
# lazy_static-1.3.0

  crates.lazy_static."1.3.0" = deps: { features?(features_."lazy_static"."1.3.0" deps {}) }: buildRustCrate {
    crateName = "lazy_static";
    version = "1.3.0";
    description = "A macro for declaring lazily evaluated statics in Rust.";
    authors = [ "Marvin Löbel <loebel.marvin@gmail.com>" ];
    sha256 = "1vv47va18ydk7dx5paz88g3jy1d3lwbx6qpxkbj8gyfv770i4b1y";
    dependencies = mapFeatures features ([
]);
    features = mkFeatures (features."lazy_static"."1.3.0" or {});
  };
  features_."lazy_static"."1.3.0" = deps: f: updateFeatures f (rec {
    lazy_static = fold recursiveUpdate {} [
      { "1.3.0"."spin" =
        (f.lazy_static."1.3.0"."spin" or false) ||
        (f.lazy_static."1.3.0"."spin_no_std" or false) ||
        (lazy_static."1.3.0"."spin_no_std" or false); }
      { "1.3.0".default = (f.lazy_static."1.3.0".default or true); }
    ];
  }) [];


# end
# libc-0.2.62

  crates.libc."0.2.62" = deps: { features?(features_."libc"."0.2.62" deps {}) }: buildRustCrate {
    crateName = "libc";
    version = "0.2.62";
    description = "Raw FFI bindings to platform libraries like libc.
";
    homepage = "https://github.com/rust-lang/libc";
    authors = [ "The Rust Project Developers" ];
    sha256 = "1vsb4pyn6gl6sri6cv5hin5wjfgk7lk2bshzmxb1xnkckjhz4gbx";
    build = "build.rs";
    dependencies = mapFeatures features ([
]);
    features = mkFeatures (features."libc"."0.2.62" or {});
  };
  features_."libc"."0.2.62" = deps: f: updateFeatures f (rec {
    libc = fold recursiveUpdate {} [
      { "0.2.62"."align" =
        (f.libc."0.2.62"."align" or false) ||
        (f.libc."0.2.62"."rustc-dep-of-std" or false) ||
        (libc."0.2.62"."rustc-dep-of-std" or false); }
      { "0.2.62"."rustc-std-workspace-core" =
        (f.libc."0.2.62"."rustc-std-workspace-core" or false) ||
        (f.libc."0.2.62"."rustc-dep-of-std" or false) ||
        (libc."0.2.62"."rustc-dep-of-std" or false); }
      { "0.2.62"."std" =
        (f.libc."0.2.62"."std" or false) ||
        (f.libc."0.2.62"."default" or false) ||
        (libc."0.2.62"."default" or false) ||
        (f.libc."0.2.62"."use_std" or false) ||
        (libc."0.2.62"."use_std" or false); }
      { "0.2.62".default = (f.libc."0.2.62".default or true); }
    ];
  }) [];


# end
# log-0.4.7

  crates.log."0.4.7" = deps: { features?(features_."log"."0.4.7" deps {}) }: buildRustCrate {
    crateName = "log";
    version = "0.4.7";
    description = "A lightweight logging facade for Rust
";
    authors = [ "The Rust Project Developers" ];
    sha256 = "0l5y0kd63l6mpw68r74asgk59rwqxmcjz8azjk9fax04r3gyzh05";
    build = "build.rs";
    dependencies = mapFeatures features ([
      (crates."cfg_if"."${deps."log"."0.4.7"."cfg_if"}" deps)
    ]);
    features = mkFeatures (features."log"."0.4.7" or {});
  };
  features_."log"."0.4.7" = deps: f: updateFeatures f (rec {
    cfg_if."${deps.log."0.4.7".cfg_if}".default = true;
    log."0.4.7".default = (f.log."0.4.7".default or true);
  }) [
    (if deps."log"."0.4.7" ? "cfg_if" then features_.cfg_if."${deps."log"."0.4.7"."cfg_if" or ""}" deps else {})
  ];


# end
# matrixmultiply-0.1.15

  crates.matrixmultiply."0.1.15" = deps: { features?(features_."matrixmultiply"."0.1.15" deps {}) }: buildRustCrate {
    crateName = "matrixmultiply";
    version = "0.1.15";
    description = "General matrix multiplication of f32 and f64 matrices in Rust. Supports matrices with general strides. Uses a microkernel strategy, so that the implementation is easy to parallelize and optimize. `RUSTFLAGS=\\\"-C target-cpu=native\\\"` is your friend here.";
    authors = [ "bluss" ];
    sha256 = "0ix1i4lnkfqnzv8f9wr34bf0mlr1sx5hr7yr70k4npxmwxscvdj5";
    build = "build.rs";
    dependencies = mapFeatures features ([
      (crates."rawpointer"."${deps."matrixmultiply"."0.1.15"."rawpointer"}" deps)
    ]);
  };
  features_."matrixmultiply"."0.1.15" = deps: f: updateFeatures f (rec {
    matrixmultiply."0.1.15".default = (f.matrixmultiply."0.1.15".default or true);
    rawpointer."${deps.matrixmultiply."0.1.15".rawpointer}".default = true;
  }) [
    (if deps."matrixmultiply"."0.1.15" ? "rawpointer" then features_.rawpointer."${deps."matrixmultiply"."0.1.15"."rawpointer" or ""}" deps else {})
  ];


# end
# memchr-2.2.1

  crates.memchr."2.2.1" = deps: { features?(features_."memchr"."2.2.1" deps {}) }: buildRustCrate {
    crateName = "memchr";
    version = "2.2.1";
    description = "Safe interface to memchr.";
    homepage = "https://github.com/BurntSushi/rust-memchr";
    authors = [ "Andrew Gallant <jamslam@gmail.com>" "bluss" ];
    sha256 = "1mj5z8lhz6jbapslpq8a39pwcsl1p0jmgp7wgcj7nv4pcqhya7a0";
    dependencies = mapFeatures features ([
]);
    features = mkFeatures (features."memchr"."2.2.1" or {});
  };
  features_."memchr"."2.2.1" = deps: f: updateFeatures f (rec {
    memchr = fold recursiveUpdate {} [
      { "2.2.1"."use_std" =
        (f.memchr."2.2.1"."use_std" or false) ||
        (f.memchr."2.2.1"."default" or false) ||
        (memchr."2.2.1"."default" or false); }
      { "2.2.1".default = (f.memchr."2.2.1".default or true); }
    ];
  }) [];


# end
# memmap-0.7.0

  crates.memmap."0.7.0" = deps: { features?(features_."memmap"."0.7.0" deps {}) }: buildRustCrate {
    crateName = "memmap";
    version = "0.7.0";
    description = "Cross-platform Rust API for memory-mapped file IO";
    authors = [ "Dan Burkert <dan@danburkert.com>" ];
    sha256 = "1j1rz5p4vh3i5p6rxy620wypj36xc7qarw6dj3353ym67zfaml18";
    dependencies = (if (kernel == "linux" || kernel == "darwin") then mapFeatures features ([
      (crates."libc"."${deps."memmap"."0.7.0"."libc"}" deps)
    ]) else [])
      ++ (if kernel == "windows" then mapFeatures features ([
      (crates."winapi"."${deps."memmap"."0.7.0"."winapi"}" deps)
    ]) else []);
  };
  features_."memmap"."0.7.0" = deps: f: updateFeatures f (rec {
    libc."${deps.memmap."0.7.0".libc}".default = true;
    memmap."0.7.0".default = (f.memmap."0.7.0".default or true);
    winapi = fold recursiveUpdate {} [
      { "${deps.memmap."0.7.0".winapi}"."basetsd" = true; }
      { "${deps.memmap."0.7.0".winapi}"."handleapi" = true; }
      { "${deps.memmap."0.7.0".winapi}"."memoryapi" = true; }
      { "${deps.memmap."0.7.0".winapi}"."minwindef" = true; }
      { "${deps.memmap."0.7.0".winapi}"."std" = true; }
      { "${deps.memmap."0.7.0".winapi}"."sysinfoapi" = true; }
      { "${deps.memmap."0.7.0".winapi}".default = true; }
    ];
  }) [
    (if deps."memmap"."0.7.0" ? "libc" then features_.libc."${deps."memmap"."0.7.0"."libc" or ""}" deps else {})
    (if deps."memmap"."0.7.0" ? "winapi" then features_.winapi."${deps."memmap"."0.7.0"."winapi" or ""}" deps else {})
  ];


# end
# memoffset-0.2.1

  crates.memoffset."0.2.1" = deps: { features?(features_."memoffset"."0.2.1" deps {}) }: buildRustCrate {
    crateName = "memoffset";
    version = "0.2.1";
    description = "offset_of functionality for Rust structs.";
    authors = [ "Gilad Naaman <gilad.naaman@gmail.com>" ];
    sha256 = "00vym01jk9slibq2nsiilgffp7n6k52a4q3n4dqp0xf5kzxvffcf";
  };
  features_."memoffset"."0.2.1" = deps: f: updateFeatures f (rec {
    memoffset."0.2.1".default = (f.memoffset."0.2.1".default or true);
  }) [];


# end
# ndarray-0.12.1

  crates.ndarray."0.12.1" = deps: { features?(features_."ndarray"."0.12.1" deps {}) }: buildRustCrate {
    crateName = "ndarray";
    version = "0.12.1";
    description = "An n-dimensional array for general elements and for numerics. Lightweight array views and slicing; views support chunking and splitting.";
    authors = [ "bluss" "Jim Turner" ];
    sha256 = "13708k97kdjfj6g4z1yapjln0v4m7zj0114h8snw44fj79l00346";
    build = "build.rs";
    dependencies = mapFeatures features ([
      (crates."itertools"."${deps."ndarray"."0.12.1"."itertools"}" deps)
      (crates."matrixmultiply"."${deps."ndarray"."0.12.1"."matrixmultiply"}" deps)
      (crates."num_complex"."${deps."ndarray"."0.12.1"."num_complex"}" deps)
      (crates."num_traits"."${deps."ndarray"."0.12.1"."num_traits"}" deps)
    ]);
    features = mkFeatures (features."ndarray"."0.12.1" or {});
  };
  features_."ndarray"."0.12.1" = deps: f: updateFeatures f (rec {
    itertools."${deps.ndarray."0.12.1".itertools}".default = (f.itertools."${deps.ndarray."0.12.1".itertools}".default or false);
    matrixmultiply."${deps.ndarray."0.12.1".matrixmultiply}".default = true;
    ndarray = fold recursiveUpdate {} [
      { "0.12.1"."blas" =
        (f.ndarray."0.12.1"."blas" or false) ||
        (f.ndarray."0.12.1"."test-blas-openblas-sys" or false) ||
        (ndarray."0.12.1"."test-blas-openblas-sys" or false); }
      { "0.12.1"."blas-src" =
        (f.ndarray."0.12.1"."blas-src" or false) ||
        (f.ndarray."0.12.1"."blas" or false) ||
        (ndarray."0.12.1"."blas" or false); }
      { "0.12.1"."cblas-sys" =
        (f.ndarray."0.12.1"."cblas-sys" or false) ||
        (f.ndarray."0.12.1"."blas" or false) ||
        (ndarray."0.12.1"."blas" or false); }
      { "0.12.1"."rustc-serialize" =
        (f.ndarray."0.12.1"."rustc-serialize" or false) ||
        (f.ndarray."0.12.1"."docs" or false) ||
        (ndarray."0.12.1"."docs" or false); }
      { "0.12.1"."serde" =
        (f.ndarray."0.12.1"."serde" or false) ||
        (f.ndarray."0.12.1"."serde-1" or false) ||
        (ndarray."0.12.1"."serde-1" or false); }
      { "0.12.1"."serde-1" =
        (f.ndarray."0.12.1"."serde-1" or false) ||
        (f.ndarray."0.12.1"."docs" or false) ||
        (ndarray."0.12.1"."docs" or false); }
      { "0.12.1"."test-blas-openblas-sys" =
        (f.ndarray."0.12.1"."test-blas-openblas-sys" or false) ||
        (f.ndarray."0.12.1"."test" or false) ||
        (ndarray."0.12.1"."test" or false); }
      { "0.12.1".default = (f.ndarray."0.12.1".default or true); }
    ];
    num_complex."${deps.ndarray."0.12.1".num_complex}".default = true;
    num_traits."${deps.ndarray."0.12.1".num_traits}".default = true;
  }) [
    (if deps."ndarray"."0.12.1" ? "itertools" then features_.itertools."${deps."ndarray"."0.12.1"."itertools" or ""}" deps else {})
    (if deps."ndarray"."0.12.1" ? "matrixmultiply" then features_.matrixmultiply."${deps."ndarray"."0.12.1"."matrixmultiply" or ""}" deps else {})
    (if deps."ndarray"."0.12.1" ? "num_complex" then features_.num_complex."${deps."ndarray"."0.12.1"."num_complex" or ""}" deps else {})
    (if deps."ndarray"."0.12.1" ? "num_traits" then features_.num_traits."${deps."ndarray"."0.12.1"."num_traits" or ""}" deps else {})
  ];


# end
# ndarray-parallel-0.9.0

  crates.ndarray_parallel."0.9.0" = deps: { features?(features_."ndarray_parallel"."0.9.0" deps {}) }: buildRustCrate {
    crateName = "ndarray-parallel";
    version = "0.9.0";
    description = "Parallelization for ndarray (using rayon).";
    authors = [ "bluss" ];
    sha256 = "1y3hyiry8jrk5i1wd7a95r9s3x2shmlv8wrbhnfkbrg8h5h39p17";
    dependencies = mapFeatures features ([
      (crates."ndarray"."${deps."ndarray_parallel"."0.9.0"."ndarray"}" deps)
      (crates."rayon"."${deps."ndarray_parallel"."0.9.0"."rayon"}" deps)
    ]);
  };
  features_."ndarray_parallel"."0.9.0" = deps: f: updateFeatures f (rec {
    ndarray."${deps.ndarray_parallel."0.9.0".ndarray}".default = true;
    ndarray_parallel."0.9.0".default = (f.ndarray_parallel."0.9.0".default or true);
    rayon."${deps.ndarray_parallel."0.9.0".rayon}".default = true;
  }) [
    (if deps."ndarray_parallel"."0.9.0" ? "ndarray" then features_.ndarray."${deps."ndarray_parallel"."0.9.0"."ndarray" or ""}" deps else {})
    (if deps."ndarray_parallel"."0.9.0" ? "rayon" then features_.rayon."${deps."ndarray_parallel"."0.9.0"."rayon" or ""}" deps else {})
  ];


# end
# nodrop-0.1.13

  crates.nodrop."0.1.13" = deps: { features?(features_."nodrop"."0.1.13" deps {}) }: buildRustCrate {
    crateName = "nodrop";
    version = "0.1.13";
    description = "A wrapper type to inhibit drop (destructor). Use std::mem::ManuallyDrop instead!";
    authors = [ "bluss" ];
    sha256 = "0gkfx6wihr9z0m8nbdhma5pyvbipznjpkzny2d4zkc05b0vnhinb";
    dependencies = mapFeatures features ([
]);
    features = mkFeatures (features."nodrop"."0.1.13" or {});
  };
  features_."nodrop"."0.1.13" = deps: f: updateFeatures f (rec {
    nodrop = fold recursiveUpdate {} [
      { "0.1.13"."nodrop-union" =
        (f.nodrop."0.1.13"."nodrop-union" or false) ||
        (f.nodrop."0.1.13"."use_union" or false) ||
        (nodrop."0.1.13"."use_union" or false); }
      { "0.1.13"."std" =
        (f.nodrop."0.1.13"."std" or false) ||
        (f.nodrop."0.1.13"."default" or false) ||
        (nodrop."0.1.13"."default" or false); }
      { "0.1.13".default = (f.nodrop."0.1.13".default or true); }
    ];
  }) [];


# end
# num-complex-0.2.3

  crates.num_complex."0.2.3" = deps: { features?(features_."num_complex"."0.2.3" deps {}) }: buildRustCrate {
    crateName = "num-complex";
    version = "0.2.3";
    description = "Complex numbers implementation for Rust";
    homepage = "https://github.com/rust-num/num-complex";
    authors = [ "The Rust Project Developers" ];
    sha256 = "1l8gwn4cqhx77wzhzslwxhryrr5h4vsv19ys8wr5xb1g332805m9";
    build = "build.rs";
    dependencies = mapFeatures features ([
      (crates."num_traits"."${deps."num_complex"."0.2.3"."num_traits"}" deps)
    ]);

    buildDependencies = mapFeatures features ([
      (crates."autocfg"."${deps."num_complex"."0.2.3"."autocfg"}" deps)
    ]);
    features = mkFeatures (features."num_complex"."0.2.3" or {});
  };
  features_."num_complex"."0.2.3" = deps: f: updateFeatures f (rec {
    autocfg."${deps.num_complex."0.2.3".autocfg}".default = true;
    num_complex = fold recursiveUpdate {} [
      { "0.2.3"."std" =
        (f.num_complex."0.2.3"."std" or false) ||
        (f.num_complex."0.2.3"."default" or false) ||
        (num_complex."0.2.3"."default" or false); }
      { "0.2.3".default = (f.num_complex."0.2.3".default or true); }
    ];
    num_traits = fold recursiveUpdate {} [
      { "${deps.num_complex."0.2.3".num_traits}"."i128" =
        (f.num_traits."${deps.num_complex."0.2.3".num_traits}"."i128" or false) ||
        (num_complex."0.2.3"."i128" or false) ||
        (f."num_complex"."0.2.3"."i128" or false); }
      { "${deps.num_complex."0.2.3".num_traits}"."std" =
        (f.num_traits."${deps.num_complex."0.2.3".num_traits}"."std" or false) ||
        (num_complex."0.2.3"."std" or false) ||
        (f."num_complex"."0.2.3"."std" or false); }
      { "${deps.num_complex."0.2.3".num_traits}".default = (f.num_traits."${deps.num_complex."0.2.3".num_traits}".default or false); }
    ];
  }) [
    (if deps."num_complex"."0.2.3" ? "num_traits" then features_.num_traits."${deps."num_complex"."0.2.3"."num_traits" or ""}" deps else {})
    (if deps."num_complex"."0.2.3" ? "autocfg" then features_.autocfg."${deps."num_complex"."0.2.3"."autocfg" or ""}" deps else {})
  ];


# end
# num-traits-0.2.8

  crates.num_traits."0.2.8" = deps: { features?(features_."num_traits"."0.2.8" deps {}) }: buildRustCrate {
    crateName = "num-traits";
    version = "0.2.8";
    description = "Numeric traits for generic mathematics";
    homepage = "https://github.com/rust-num/num-traits";
    authors = [ "The Rust Project Developers" ];
    sha256 = "1mnlmy35n734n9xlq0qkfbgzz33x09a1s4rfj30p1976p09b862v";
    build = "build.rs";

    buildDependencies = mapFeatures features ([
      (crates."autocfg"."${deps."num_traits"."0.2.8"."autocfg"}" deps)
    ]);
    features = mkFeatures (features."num_traits"."0.2.8" or {});
  };
  features_."num_traits"."0.2.8" = deps: f: updateFeatures f (rec {
    autocfg."${deps.num_traits."0.2.8".autocfg}".default = true;
    num_traits = fold recursiveUpdate {} [
      { "0.2.8"."std" =
        (f.num_traits."0.2.8"."std" or false) ||
        (f.num_traits."0.2.8"."default" or false) ||
        (num_traits."0.2.8"."default" or false); }
      { "0.2.8".default = (f.num_traits."0.2.8".default or true); }
    ];
  }) [
    (if deps."num_traits"."0.2.8" ? "autocfg" then features_.autocfg."${deps."num_traits"."0.2.8"."autocfg" or ""}" deps else {})
  ];


# end
# num_cpus-1.10.1

  crates.num_cpus."1.10.1" = deps: { features?(features_."num_cpus"."1.10.1" deps {}) }: buildRustCrate {
    crateName = "num_cpus";
    version = "1.10.1";
    description = "Get the number of CPUs on a machine.";
    authors = [ "Sean McArthur <sean@seanmonstar.com>" ];
    sha256 = "1zi5s2cbnqqb0k0kdd6gqn2x97f9bssv44430h6w28awwzppyh8i";
    dependencies = mapFeatures features ([
      (crates."libc"."${deps."num_cpus"."1.10.1"."libc"}" deps)
    ]);
  };
  features_."num_cpus"."1.10.1" = deps: f: updateFeatures f (rec {
    libc."${deps.num_cpus."1.10.1".libc}".default = true;
    num_cpus."1.10.1".default = (f.num_cpus."1.10.1".default or true);
  }) [
    (if deps."num_cpus"."1.10.1" ? "libc" then features_.libc."${deps."num_cpus"."1.10.1"."libc" or ""}" deps else {})
  ];


# end
# numpy-0.7.0

  crates.numpy."0.7.0" = deps: { features?(features_."numpy"."0.7.0" deps {}) }: buildRustCrate {
    crateName = "numpy";
    version = "0.7.0";
    description = "Rust binding of NumPy C-API";
    authors = [ "Toshiki Teramura <toshiki.teramura@gmail.com>" "Yuji Kanagawa <yuji.kngw.80s.revive@gmail.com>" ];
    edition = "2018";
    sha256 = "1qa5dkidxwmiha42l847pnpqmqhvcfkxbc90qvfb7m1yn5bca7q3";
    dependencies = mapFeatures features ([
      (crates."cfg_if"."${deps."numpy"."0.7.0"."cfg_if"}" deps)
      (crates."libc"."${deps."numpy"."0.7.0"."libc"}" deps)
      (crates."ndarray"."${deps."numpy"."0.7.0"."ndarray"}" deps)
      (crates."num_complex"."${deps."numpy"."0.7.0"."num_complex"}" deps)
      (crates."num_traits"."${deps."numpy"."0.7.0"."num_traits"}" deps)
      (crates."pyo3"."${deps."numpy"."0.7.0"."pyo3"}" deps)
    ]);
    features = mkFeatures (features."numpy"."0.7.0" or {});
  };
  features_."numpy"."0.7.0" = deps: f: updateFeatures f (rec {
    cfg_if."${deps.numpy."0.7.0".cfg_if}".default = true;
    libc."${deps.numpy."0.7.0".libc}".default = true;
    ndarray."${deps.numpy."0.7.0".ndarray}".default = true;
    num_complex."${deps.numpy."0.7.0".num_complex}".default = true;
    num_traits."${deps.numpy."0.7.0".num_traits}".default = true;
    numpy."0.7.0".default = (f.numpy."0.7.0".default or true);
    pyo3 = fold recursiveUpdate {} [
      { "${deps.numpy."0.7.0".pyo3}"."python3" =
        (f.pyo3."${deps.numpy."0.7.0".pyo3}"."python3" or false) ||
        (numpy."0.7.0"."python3" or false) ||
        (f."numpy"."0.7.0"."python3" or false); }
      { "${deps.numpy."0.7.0".pyo3}".default = true; }
    ];
  }) [
    (if deps."numpy"."0.7.0" ? "cfg_if" then features_.cfg_if."${deps."numpy"."0.7.0"."cfg_if" or ""}" deps else {})
    (if deps."numpy"."0.7.0" ? "libc" then features_.libc."${deps."numpy"."0.7.0"."libc" or ""}" deps else {})
    (if deps."numpy"."0.7.0" ? "ndarray" then features_.ndarray."${deps."numpy"."0.7.0"."ndarray" or ""}" deps else {})
    (if deps."numpy"."0.7.0" ? "num_complex" then features_.num_complex."${deps."numpy"."0.7.0"."num_complex" or ""}" deps else {})
    (if deps."numpy"."0.7.0" ? "num_traits" then features_.num_traits."${deps."numpy"."0.7.0"."num_traits" or ""}" deps else {})
    (if deps."numpy"."0.7.0" ? "pyo3" then features_.pyo3."${deps."numpy"."0.7.0"."pyo3" or ""}" deps else {})
  ];


# end
# ordered-float-1.0.2

  crates.ordered_float."1.0.2" = deps: { features?(features_."ordered_float"."1.0.2" deps {}) }: buildRustCrate {
    crateName = "ordered-float";
    version = "1.0.2";
    description = "Wrappers for total ordering on floats";
    authors = [ "Jonathan Reem <jonathan.reem@gmail.com>" "Matt Brubeck <mbrubeck@limpet.net>" ];
    sha256 = "1bwjh1gkh2n6zqb2q1a04gkskgz3hxbj3w7fvhx6yd7l0nbmbd1b";
    dependencies = mapFeatures features ([
      (crates."num_traits"."${deps."ordered_float"."1.0.2"."num_traits"}" deps)
    ]);
    features = mkFeatures (features."ordered_float"."1.0.2" or {});
  };
  features_."ordered_float"."1.0.2" = deps: f: updateFeatures f (rec {
    num_traits = fold recursiveUpdate {} [
      { "${deps.ordered_float."1.0.2".num_traits}"."std" =
        (f.num_traits."${deps.ordered_float."1.0.2".num_traits}"."std" or false) ||
        (ordered_float."1.0.2"."std" or false) ||
        (f."ordered_float"."1.0.2"."std" or false); }
      { "${deps.ordered_float."1.0.2".num_traits}".default = (f.num_traits."${deps.ordered_float."1.0.2".num_traits}".default or false); }
    ];
    ordered_float = fold recursiveUpdate {} [
      { "1.0.2"."std" =
        (f.ordered_float."1.0.2"."std" or false) ||
        (f.ordered_float."1.0.2"."default" or false) ||
        (ordered_float."1.0.2"."default" or false); }
      { "1.0.2".default = (f.ordered_float."1.0.2".default or true); }
    ];
  }) [
    (if deps."ordered_float"."1.0.2" ? "num_traits" then features_.num_traits."${deps."ordered_float"."1.0.2"."num_traits" or ""}" deps else {})
  ];


# end
# paste-0.1.6

  crates.paste."0.1.6" = deps: { features?(features_."paste"."0.1.6" deps {}) }: buildRustCrate {
    crateName = "paste";
    version = "0.1.6";
    description = "Macros for all your token pasting needs";
    authors = [ "David Tolnay <dtolnay@gmail.com>" ];
    edition = "2018";
    sha256 = "1xi423qww4w5i9qli1c4jw6lz1jy1wv66achns96llyckbrpmn58";
    dependencies = mapFeatures features ([
      (crates."paste_impl"."${deps."paste"."0.1.6"."paste_impl"}" deps)
      (crates."proc_macro_hack"."${deps."paste"."0.1.6"."proc_macro_hack"}" deps)
    ]);
  };
  features_."paste"."0.1.6" = deps: f: updateFeatures f (rec {
    paste."0.1.6".default = (f.paste."0.1.6".default or true);
    paste_impl."${deps.paste."0.1.6".paste_impl}".default = true;
    proc_macro_hack."${deps.paste."0.1.6".proc_macro_hack}".default = true;
  }) [
    (if deps."paste"."0.1.6" ? "paste_impl" then features_.paste_impl."${deps."paste"."0.1.6"."paste_impl" or ""}" deps else {})
    (if deps."paste"."0.1.6" ? "proc_macro_hack" then features_.proc_macro_hack."${deps."paste"."0.1.6"."proc_macro_hack" or ""}" deps else {})
  ];


# end
# paste-impl-0.1.6

  crates.paste_impl."0.1.6" = deps: { features?(features_."paste_impl"."0.1.6" deps {}) }: buildRustCrate {
    crateName = "paste-impl";
    version = "0.1.6";
    description = "Implementation detail of the `paste` crate";
    authors = [ "David Tolnay <dtolnay@gmail.com>" ];
    edition = "2018";
    sha256 = "05g0fp8h257gic2iji15h9sf241752x2804c0z50s2ifp0w7jyc6";
    procMacro = true;
    dependencies = mapFeatures features ([
      (crates."proc_macro_hack"."${deps."paste_impl"."0.1.6"."proc_macro_hack"}" deps)
      (crates."proc_macro2"."${deps."paste_impl"."0.1.6"."proc_macro2"}" deps)
      (crates."quote"."${deps."paste_impl"."0.1.6"."quote"}" deps)
      (crates."syn"."${deps."paste_impl"."0.1.6"."syn"}" deps)
    ]);
  };
  features_."paste_impl"."0.1.6" = deps: f: updateFeatures f (rec {
    paste_impl."0.1.6".default = (f.paste_impl."0.1.6".default or true);
    proc_macro2."${deps.paste_impl."0.1.6".proc_macro2}".default = true;
    proc_macro_hack."${deps.paste_impl."0.1.6".proc_macro_hack}".default = true;
    quote."${deps.paste_impl."0.1.6".quote}".default = true;
    syn."${deps.paste_impl."0.1.6".syn}".default = true;
  }) [
    (if deps."paste_impl"."0.1.6" ? "proc_macro_hack" then features_.proc_macro_hack."${deps."paste_impl"."0.1.6"."proc_macro_hack" or ""}" deps else {})
    (if deps."paste_impl"."0.1.6" ? "proc_macro2" then features_.proc_macro2."${deps."paste_impl"."0.1.6"."proc_macro2" or ""}" deps else {})
    (if deps."paste_impl"."0.1.6" ? "quote" then features_.quote."${deps."paste_impl"."0.1.6"."quote" or ""}" deps else {})
    (if deps."paste_impl"."0.1.6" ? "syn" then features_.syn."${deps."paste_impl"."0.1.6"."syn" or ""}" deps else {})
  ];


# end
# proc-macro-hack-0.5.9

  crates.proc_macro_hack."0.5.9" = deps: { features?(features_."proc_macro_hack"."0.5.9" deps {}) }: buildRustCrate {
    crateName = "proc-macro-hack";
    version = "0.5.9";
    description = "Procedural macros in expression position";
    authors = [ "David Tolnay <dtolnay@gmail.com>" ];
    sha256 = "1w99ilwdwl0xdg6bxv6i8z9zlr00n8i28npcf7f212s07jphagig";
    procMacro = true;
    dependencies = mapFeatures features ([
      (crates."proc_macro2"."${deps."proc_macro_hack"."0.5.9"."proc_macro2"}" deps)
      (crates."quote"."${deps."proc_macro_hack"."0.5.9"."quote"}" deps)
      (crates."syn"."${deps."proc_macro_hack"."0.5.9"."syn"}" deps)
    ]);
  };
  features_."proc_macro_hack"."0.5.9" = deps: f: updateFeatures f (rec {
    proc_macro2."${deps.proc_macro_hack."0.5.9".proc_macro2}".default = true;
    proc_macro_hack."0.5.9".default = (f.proc_macro_hack."0.5.9".default or true);
    quote."${deps.proc_macro_hack."0.5.9".quote}".default = true;
    syn."${deps.proc_macro_hack."0.5.9".syn}".default = true;
  }) [
    (if deps."proc_macro_hack"."0.5.9" ? "proc_macro2" then features_.proc_macro2."${deps."proc_macro_hack"."0.5.9"."proc_macro2" or ""}" deps else {})
    (if deps."proc_macro_hack"."0.5.9" ? "quote" then features_.quote."${deps."proc_macro_hack"."0.5.9"."quote" or ""}" deps else {})
    (if deps."proc_macro_hack"."0.5.9" ? "syn" then features_.syn."${deps."proc_macro_hack"."0.5.9"."syn" or ""}" deps else {})
  ];


# end
# proc-macro2-0.4.30

  crates.proc_macro2."0.4.30" = deps: { features?(features_."proc_macro2"."0.4.30" deps {}) }: buildRustCrate {
    crateName = "proc-macro2";
    version = "0.4.30";
    description = "A stable implementation of the upcoming new `proc_macro` API. Comes with an
option, off by default, to also reimplement itself in terms of the upstream
unstable API.
";
    homepage = "https://github.com/alexcrichton/proc-macro2";
    authors = [ "Alex Crichton <alex@alexcrichton.com>" ];
    sha256 = "0iifv51wrm6r4r2gghw6rray3nv53zcap355bbz1nsmbhj5s09b9";
    build = "build.rs";
    dependencies = mapFeatures features ([
      (crates."unicode_xid"."${deps."proc_macro2"."0.4.30"."unicode_xid"}" deps)
    ]);
    features = mkFeatures (features."proc_macro2"."0.4.30" or {});
  };
  features_."proc_macro2"."0.4.30" = deps: f: updateFeatures f (rec {
    proc_macro2 = fold recursiveUpdate {} [
      { "0.4.30"."proc-macro" =
        (f.proc_macro2."0.4.30"."proc-macro" or false) ||
        (f.proc_macro2."0.4.30"."default" or false) ||
        (proc_macro2."0.4.30"."default" or false); }
      { "0.4.30".default = (f.proc_macro2."0.4.30".default or true); }
    ];
    unicode_xid."${deps.proc_macro2."0.4.30".unicode_xid}".default = true;
  }) [
    (if deps."proc_macro2"."0.4.30" ? "unicode_xid" then features_.unicode_xid."${deps."proc_macro2"."0.4.30"."unicode_xid" or ""}" deps else {})
  ];


# end
# proc-macro2-1.0.3

  crates.proc_macro2."1.0.3" = deps: { features?(features_."proc_macro2"."1.0.3" deps {}) }: buildRustCrate {
    crateName = "proc-macro2";
    version = "1.0.3";
    description = "A stable implementation of the upcoming new `proc_macro` API. Comes with an
option, off by default, to also reimplement itself in terms of the upstream
unstable API.
";
    homepage = "https://github.com/alexcrichton/proc-macro2";
    authors = [ "Alex Crichton <alex@alexcrichton.com>" ];
    edition = "2018";
    sha256 = "0qv29h6pz6n0b4qi8w240l3xppsw26bk5ga2vcjk3nhji0nsplwk";
    libName = "proc_macro2";
    dependencies = mapFeatures features ([
      (crates."unicode_xid"."${deps."proc_macro2"."1.0.3"."unicode_xid"}" deps)
    ]);
    features = mkFeatures (features."proc_macro2"."1.0.3" or {});
  };
  features_."proc_macro2"."1.0.3" = deps: f: updateFeatures f (rec {
    proc_macro2 = fold recursiveUpdate {} [
      { "1.0.3"."proc-macro" =
        (f.proc_macro2."1.0.3"."proc-macro" or false) ||
        (f.proc_macro2."1.0.3"."default" or false) ||
        (proc_macro2."1.0.3"."default" or false); }
      { "1.0.3".default = (f.proc_macro2."1.0.3".default or true); }
    ];
    unicode_xid."${deps.proc_macro2."1.0.3".unicode_xid}".default = true;
  }) [
    (if deps."proc_macro2"."1.0.3" ? "unicode_xid" then features_.unicode_xid."${deps."proc_macro2"."1.0.3"."unicode_xid" or ""}" deps else {})
  ];


# end
# pyo3-0.8.0

  crates.pyo3."0.8.0" = deps: { features?(features_."pyo3"."0.8.0" deps {}) }: buildRustCrate {
    crateName = "pyo3";
    version = "0.8.0";
    description = "Bindings to Python interpreter";
    homepage = "https://github.com/pyo3/pyo3";
    authors = [ "PyO3 Project and Contributors <https://github.com/PyO3>" ];
    edition = "2018";
    sha256 = "06lyk9kznsw391f2w777p0ipigrxssijmiklhxdj34kn7kygrwd6";
    build = "build.rs";
    dependencies = mapFeatures features ([
      (crates."indoc"."${deps."pyo3"."0.8.0"."indoc"}" deps)
      (crates."inventory"."${deps."pyo3"."0.8.0"."inventory"}" deps)
      (crates."libc"."${deps."pyo3"."0.8.0"."libc"}" deps)
      (crates."num_traits"."${deps."pyo3"."0.8.0"."num_traits"}" deps)
      (crates."paste"."${deps."pyo3"."0.8.0"."paste"}" deps)
      (crates."pyo3cls"."${deps."pyo3"."0.8.0"."pyo3cls"}" deps)
      (crates."spin"."${deps."pyo3"."0.8.0"."spin"}" deps)
      (crates."unindent"."${deps."pyo3"."0.8.0"."unindent"}" deps)
    ]);

    buildDependencies = mapFeatures features ([
      (crates."regex"."${deps."pyo3"."0.8.0"."regex"}" deps)
      (crates."serde"."${deps."pyo3"."0.8.0"."serde"}" deps)
      (crates."serde_json"."${deps."pyo3"."0.8.0"."serde_json"}" deps)
      (crates."version_check"."${deps."pyo3"."0.8.0"."version_check"}" deps)
    ]);
    features = mkFeatures (features."pyo3"."0.8.0" or {});
  };
  features_."pyo3"."0.8.0" = deps: f: updateFeatures f (rec {
    indoc."${deps.pyo3."0.8.0".indoc}".default = true;
    inventory."${deps.pyo3."0.8.0".inventory}".default = true;
    libc."${deps.pyo3."0.8.0".libc}".default = true;
    num_traits."${deps.pyo3."0.8.0".num_traits}".default = true;
    paste."${deps.pyo3."0.8.0".paste}".default = true;
    pyo3."0.8.0".default = (f.pyo3."0.8.0".default or true);
    pyo3cls = fold recursiveUpdate {} [
      { "${deps.pyo3."0.8.0".pyo3cls}"."unsound-subclass" =
        (f.pyo3cls."${deps.pyo3."0.8.0".pyo3cls}"."unsound-subclass" or false) ||
        (pyo3."0.8.0"."unsound-subclass" or false) ||
        (f."pyo3"."0.8.0"."unsound-subclass" or false); }
      { "${deps.pyo3."0.8.0".pyo3cls}".default = true; }
    ];
    regex."${deps.pyo3."0.8.0".regex}".default = true;
    serde = fold recursiveUpdate {} [
      { "${deps.pyo3."0.8.0".serde}"."derive" = true; }
      { "${deps.pyo3."0.8.0".serde}".default = true; }
    ];
    serde_json."${deps.pyo3."0.8.0".serde_json}".default = true;
    spin."${deps.pyo3."0.8.0".spin}".default = true;
    unindent."${deps.pyo3."0.8.0".unindent}".default = true;
    version_check."${deps.pyo3."0.8.0".version_check}".default = true;
  }) [
    (if deps."pyo3"."0.8.0" ? "indoc" then features_.indoc."${deps."pyo3"."0.8.0"."indoc" or ""}" deps else {})
    (if deps."pyo3"."0.8.0" ? "inventory" then features_.inventory."${deps."pyo3"."0.8.0"."inventory" or ""}" deps else {})
    (if deps."pyo3"."0.8.0" ? "libc" then features_.libc."${deps."pyo3"."0.8.0"."libc" or ""}" deps else {})
    (if deps."pyo3"."0.8.0" ? "num_traits" then features_.num_traits."${deps."pyo3"."0.8.0"."num_traits" or ""}" deps else {})
    (if deps."pyo3"."0.8.0" ? "paste" then features_.paste."${deps."pyo3"."0.8.0"."paste" or ""}" deps else {})
    (if deps."pyo3"."0.8.0" ? "pyo3cls" then features_.pyo3cls."${deps."pyo3"."0.8.0"."pyo3cls" or ""}" deps else {})
    (if deps."pyo3"."0.8.0" ? "spin" then features_.spin."${deps."pyo3"."0.8.0"."spin" or ""}" deps else {})
    (if deps."pyo3"."0.8.0" ? "unindent" then features_.unindent."${deps."pyo3"."0.8.0"."unindent" or ""}" deps else {})
    (if deps."pyo3"."0.8.0" ? "regex" then features_.regex."${deps."pyo3"."0.8.0"."regex" or ""}" deps else {})
    (if deps."pyo3"."0.8.0" ? "serde" then features_.serde."${deps."pyo3"."0.8.0"."serde" or ""}" deps else {})
    (if deps."pyo3"."0.8.0" ? "serde_json" then features_.serde_json."${deps."pyo3"."0.8.0"."serde_json" or ""}" deps else {})
    (if deps."pyo3"."0.8.0" ? "version_check" then features_.version_check."${deps."pyo3"."0.8.0"."version_check" or ""}" deps else {})
  ];


# end
# pyo3-derive-backend-0.8.0

  crates.pyo3_derive_backend."0.8.0" = deps: { features?(features_."pyo3_derive_backend"."0.8.0" deps {}) }: buildRustCrate {
    crateName = "pyo3-derive-backend";
    version = "0.8.0";
    description = "Code generation for PyO3 package";
    homepage = "https://github.com/pyo3/pyo3";
    authors = [ "PyO3 Project and Contributors <https://github.com/PyO3>" ];
    edition = "2018";
    sha256 = "1b37ksxsk6dflfhr542wxrcxrd22gpz8rxhxvdl0aym8infg1av0";
    dependencies = mapFeatures features ([
      (crates."proc_macro2"."${deps."pyo3_derive_backend"."0.8.0"."proc_macro2"}" deps)
      (crates."quote"."${deps."pyo3_derive_backend"."0.8.0"."quote"}" deps)
      (crates."syn"."${deps."pyo3_derive_backend"."0.8.0"."syn"}" deps)
    ]);
    features = mkFeatures (features."pyo3_derive_backend"."0.8.0" or {});
  };
  features_."pyo3_derive_backend"."0.8.0" = deps: f: updateFeatures f (rec {
    proc_macro2."${deps.pyo3_derive_backend."0.8.0".proc_macro2}".default = true;
    pyo3_derive_backend."0.8.0".default = (f.pyo3_derive_backend."0.8.0".default or true);
    quote."${deps.pyo3_derive_backend."0.8.0".quote}".default = true;
    syn = fold recursiveUpdate {} [
      { "${deps.pyo3_derive_backend."0.8.0".syn}"."extra-traits" = true; }
      { "${deps.pyo3_derive_backend."0.8.0".syn}"."full" = true; }
      { "${deps.pyo3_derive_backend."0.8.0".syn}".default = true; }
    ];
  }) [
    (if deps."pyo3_derive_backend"."0.8.0" ? "proc_macro2" then features_.proc_macro2."${deps."pyo3_derive_backend"."0.8.0"."proc_macro2" or ""}" deps else {})
    (if deps."pyo3_derive_backend"."0.8.0" ? "quote" then features_.quote."${deps."pyo3_derive_backend"."0.8.0"."quote" or ""}" deps else {})
    (if deps."pyo3_derive_backend"."0.8.0" ? "syn" then features_.syn."${deps."pyo3_derive_backend"."0.8.0"."syn" or ""}" deps else {})
  ];


# end
# pyo3cls-0.8.0

  crates.pyo3cls."0.8.0" = deps: { features?(features_."pyo3cls"."0.8.0" deps {}) }: buildRustCrate {
    crateName = "pyo3cls";
    version = "0.8.0";
    description = "Proc macros for PyO3 package";
    homepage = "https://github.com/pyo3/pyo3";
    authors = [ "PyO3 Project and Contributors <https://github.com/PyO3>" ];
    edition = "2018";
    sha256 = "0zf0jcg102ixhjffjcn8l205zpd6qqqpqiidkq26nmji3ffn8n18";
    procMacro = true;
    dependencies = mapFeatures features ([
      (crates."proc_macro2"."${deps."pyo3cls"."0.8.0"."proc_macro2"}" deps)
      (crates."pyo3_derive_backend"."${deps."pyo3cls"."0.8.0"."pyo3_derive_backend"}" deps)
      (crates."quote"."${deps."pyo3cls"."0.8.0"."quote"}" deps)
      (crates."syn"."${deps."pyo3cls"."0.8.0"."syn"}" deps)
    ]);
    features = mkFeatures (features."pyo3cls"."0.8.0" or {});
  };
  features_."pyo3cls"."0.8.0" = deps: f: updateFeatures f (rec {
    proc_macro2."${deps.pyo3cls."0.8.0".proc_macro2}".default = true;
    pyo3_derive_backend = fold recursiveUpdate {} [
      { "${deps.pyo3cls."0.8.0".pyo3_derive_backend}"."unsound-subclass" =
        (f.pyo3_derive_backend."${deps.pyo3cls."0.8.0".pyo3_derive_backend}"."unsound-subclass" or false) ||
        (pyo3cls."0.8.0"."unsound-subclass" or false) ||
        (f."pyo3cls"."0.8.0"."unsound-subclass" or false); }
      { "${deps.pyo3cls."0.8.0".pyo3_derive_backend}".default = true; }
    ];
    pyo3cls."0.8.0".default = (f.pyo3cls."0.8.0".default or true);
    quote."${deps.pyo3cls."0.8.0".quote}".default = true;
    syn = fold recursiveUpdate {} [
      { "${deps.pyo3cls."0.8.0".syn}"."extra-traits" = true; }
      { "${deps.pyo3cls."0.8.0".syn}"."full" = true; }
      { "${deps.pyo3cls."0.8.0".syn}".default = true; }
    ];
  }) [
    (if deps."pyo3cls"."0.8.0" ? "proc_macro2" then features_.proc_macro2."${deps."pyo3cls"."0.8.0"."proc_macro2" or ""}" deps else {})
    (if deps."pyo3cls"."0.8.0" ? "pyo3_derive_backend" then features_.pyo3_derive_backend."${deps."pyo3cls"."0.8.0"."pyo3_derive_backend" or ""}" deps else {})
    (if deps."pyo3cls"."0.8.0" ? "quote" then features_.quote."${deps."pyo3cls"."0.8.0"."quote" or ""}" deps else {})
    (if deps."pyo3cls"."0.8.0" ? "syn" then features_.syn."${deps."pyo3cls"."0.8.0"."syn" or ""}" deps else {})
  ];


# end
# quote-0.6.13

  crates.quote."0.6.13" = deps: { features?(features_."quote"."0.6.13" deps {}) }: buildRustCrate {
    crateName = "quote";
    version = "0.6.13";
    description = "Quasi-quoting macro quote!(...)";
    authors = [ "David Tolnay <dtolnay@gmail.com>" ];
    sha256 = "1hrvsin40i4q8swrhlj9057g7nsp0lg02h8zbzmgz14av9mzv8g8";
    dependencies = mapFeatures features ([
      (crates."proc_macro2"."${deps."quote"."0.6.13"."proc_macro2"}" deps)
    ]);
    features = mkFeatures (features."quote"."0.6.13" or {});
  };
  features_."quote"."0.6.13" = deps: f: updateFeatures f (rec {
    proc_macro2 = fold recursiveUpdate {} [
      { "${deps.quote."0.6.13".proc_macro2}"."proc-macro" =
        (f.proc_macro2."${deps.quote."0.6.13".proc_macro2}"."proc-macro" or false) ||
        (quote."0.6.13"."proc-macro" or false) ||
        (f."quote"."0.6.13"."proc-macro" or false); }
      { "${deps.quote."0.6.13".proc_macro2}".default = (f.proc_macro2."${deps.quote."0.6.13".proc_macro2}".default or false); }
    ];
    quote = fold recursiveUpdate {} [
      { "0.6.13"."proc-macro" =
        (f.quote."0.6.13"."proc-macro" or false) ||
        (f.quote."0.6.13"."default" or false) ||
        (quote."0.6.13"."default" or false); }
      { "0.6.13".default = (f.quote."0.6.13".default or true); }
    ];
  }) [
    (if deps."quote"."0.6.13" ? "proc_macro2" then features_.proc_macro2."${deps."quote"."0.6.13"."proc_macro2" or ""}" deps else {})
  ];


# end
# quote-1.0.2

  crates.quote."1.0.2" = deps: { features?(features_."quote"."1.0.2" deps {}) }: buildRustCrate {
    crateName = "quote";
    version = "1.0.2";
    description = "Quasi-quoting macro quote!(...)";
    authors = [ "David Tolnay <dtolnay@gmail.com>" ];
    edition = "2018";
    sha256 = "0r7030w7dymarn92gjgm02hsm04fwsfs6f1l20wdqiyrm9z8rs5q";
    dependencies = mapFeatures features ([
      (crates."proc_macro2"."${deps."quote"."1.0.2"."proc_macro2"}" deps)
    ]);
    features = mkFeatures (features."quote"."1.0.2" or {});
  };
  features_."quote"."1.0.2" = deps: f: updateFeatures f (rec {
    proc_macro2 = fold recursiveUpdate {} [
      { "${deps.quote."1.0.2".proc_macro2}"."proc-macro" =
        (f.proc_macro2."${deps.quote."1.0.2".proc_macro2}"."proc-macro" or false) ||
        (quote."1.0.2"."proc-macro" or false) ||
        (f."quote"."1.0.2"."proc-macro" or false); }
      { "${deps.quote."1.0.2".proc_macro2}".default = (f.proc_macro2."${deps.quote."1.0.2".proc_macro2}".default or false); }
    ];
    quote = fold recursiveUpdate {} [
      { "1.0.2"."proc-macro" =
        (f.quote."1.0.2"."proc-macro" or false) ||
        (f.quote."1.0.2"."default" or false) ||
        (quote."1.0.2"."default" or false); }
      { "1.0.2".default = (f.quote."1.0.2".default or true); }
    ];
  }) [
    (if deps."quote"."1.0.2" ? "proc_macro2" then features_.proc_macro2."${deps."quote"."1.0.2"."proc_macro2" or ""}" deps else {})
  ];


# end
# rand-0.6.5

  crates.rand."0.6.5" = deps: { features?(features_."rand"."0.6.5" deps {}) }: buildRustCrate {
    crateName = "rand";
    version = "0.6.5";
    description = "Random number generators and other randomness functionality.
";
    homepage = "https://crates.io/crates/rand";
    authors = [ "The Rand Project Developers" "The Rust Project Developers" ];
    sha256 = "0zbck48159aj8zrwzf80sd9xxh96w4f4968nshwjpysjvflimvgb";
    build = "build.rs";
    dependencies = mapFeatures features ([
      (crates."rand_chacha"."${deps."rand"."0.6.5"."rand_chacha"}" deps)
      (crates."rand_core"."${deps."rand"."0.6.5"."rand_core"}" deps)
      (crates."rand_hc"."${deps."rand"."0.6.5"."rand_hc"}" deps)
      (crates."rand_isaac"."${deps."rand"."0.6.5"."rand_isaac"}" deps)
      (crates."rand_jitter"."${deps."rand"."0.6.5"."rand_jitter"}" deps)
      (crates."rand_pcg"."${deps."rand"."0.6.5"."rand_pcg"}" deps)
      (crates."rand_xorshift"."${deps."rand"."0.6.5"."rand_xorshift"}" deps)
    ]
      ++ (if features.rand."0.6.5".rand_os or false then [ (crates.rand_os."${deps."rand"."0.6.5".rand_os}" deps) ] else []))
      ++ (if (kernel == "linux" || kernel == "darwin") then mapFeatures features ([
      (crates."libc"."${deps."rand"."0.6.5"."libc"}" deps)
    ]) else [])
      ++ (if kernel == "windows" then mapFeatures features ([
      (crates."winapi"."${deps."rand"."0.6.5"."winapi"}" deps)
    ]) else []);

    buildDependencies = mapFeatures features ([
      (crates."autocfg"."${deps."rand"."0.6.5"."autocfg"}" deps)
    ]);
    features = mkFeatures (features."rand"."0.6.5" or {});
  };
  features_."rand"."0.6.5" = deps: f: updateFeatures f (rec {
    autocfg."${deps.rand."0.6.5".autocfg}".default = true;
    libc."${deps.rand."0.6.5".libc}".default = (f.libc."${deps.rand."0.6.5".libc}".default or false);
    rand = fold recursiveUpdate {} [
      { "0.6.5"."alloc" =
        (f.rand."0.6.5"."alloc" or false) ||
        (f.rand."0.6.5"."std" or false) ||
        (rand."0.6.5"."std" or false); }
      { "0.6.5"."packed_simd" =
        (f.rand."0.6.5"."packed_simd" or false) ||
        (f.rand."0.6.5"."simd_support" or false) ||
        (rand."0.6.5"."simd_support" or false); }
      { "0.6.5"."rand_os" =
        (f.rand."0.6.5"."rand_os" or false) ||
        (f.rand."0.6.5"."std" or false) ||
        (rand."0.6.5"."std" or false); }
      { "0.6.5"."simd_support" =
        (f.rand."0.6.5"."simd_support" or false) ||
        (f.rand."0.6.5"."nightly" or false) ||
        (rand."0.6.5"."nightly" or false); }
      { "0.6.5"."std" =
        (f.rand."0.6.5"."std" or false) ||
        (f.rand."0.6.5"."default" or false) ||
        (rand."0.6.5"."default" or false); }
      { "0.6.5".default = (f.rand."0.6.5".default or true); }
    ];
    rand_chacha."${deps.rand."0.6.5".rand_chacha}".default = true;
    rand_core = fold recursiveUpdate {} [
      { "${deps.rand."0.6.5".rand_core}"."alloc" =
        (f.rand_core."${deps.rand."0.6.5".rand_core}"."alloc" or false) ||
        (rand."0.6.5"."alloc" or false) ||
        (f."rand"."0.6.5"."alloc" or false); }
      { "${deps.rand."0.6.5".rand_core}"."serde1" =
        (f.rand_core."${deps.rand."0.6.5".rand_core}"."serde1" or false) ||
        (rand."0.6.5"."serde1" or false) ||
        (f."rand"."0.6.5"."serde1" or false); }
      { "${deps.rand."0.6.5".rand_core}"."std" =
        (f.rand_core."${deps.rand."0.6.5".rand_core}"."std" or false) ||
        (rand."0.6.5"."std" or false) ||
        (f."rand"."0.6.5"."std" or false); }
      { "${deps.rand."0.6.5".rand_core}".default = true; }
    ];
    rand_hc."${deps.rand."0.6.5".rand_hc}".default = true;
    rand_isaac = fold recursiveUpdate {} [
      { "${deps.rand."0.6.5".rand_isaac}"."serde1" =
        (f.rand_isaac."${deps.rand."0.6.5".rand_isaac}"."serde1" or false) ||
        (rand."0.6.5"."serde1" or false) ||
        (f."rand"."0.6.5"."serde1" or false); }
      { "${deps.rand."0.6.5".rand_isaac}".default = true; }
    ];
    rand_jitter = fold recursiveUpdate {} [
      { "${deps.rand."0.6.5".rand_jitter}"."std" =
        (f.rand_jitter."${deps.rand."0.6.5".rand_jitter}"."std" or false) ||
        (rand."0.6.5"."std" or false) ||
        (f."rand"."0.6.5"."std" or false); }
      { "${deps.rand."0.6.5".rand_jitter}".default = true; }
    ];
    rand_os = fold recursiveUpdate {} [
      { "${deps.rand."0.6.5".rand_os}"."stdweb" =
        (f.rand_os."${deps.rand."0.6.5".rand_os}"."stdweb" or false) ||
        (rand."0.6.5"."stdweb" or false) ||
        (f."rand"."0.6.5"."stdweb" or false); }
      { "${deps.rand."0.6.5".rand_os}"."wasm-bindgen" =
        (f.rand_os."${deps.rand."0.6.5".rand_os}"."wasm-bindgen" or false) ||
        (rand."0.6.5"."wasm-bindgen" or false) ||
        (f."rand"."0.6.5"."wasm-bindgen" or false); }
    ];
    rand_pcg."${deps.rand."0.6.5".rand_pcg}".default = true;
    rand_xorshift = fold recursiveUpdate {} [
      { "${deps.rand."0.6.5".rand_xorshift}"."serde1" =
        (f.rand_xorshift."${deps.rand."0.6.5".rand_xorshift}"."serde1" or false) ||
        (rand."0.6.5"."serde1" or false) ||
        (f."rand"."0.6.5"."serde1" or false); }
      { "${deps.rand."0.6.5".rand_xorshift}".default = true; }
    ];
    winapi = fold recursiveUpdate {} [
      { "${deps.rand."0.6.5".winapi}"."minwindef" = true; }
      { "${deps.rand."0.6.5".winapi}"."ntsecapi" = true; }
      { "${deps.rand."0.6.5".winapi}"."profileapi" = true; }
      { "${deps.rand."0.6.5".winapi}"."winnt" = true; }
      { "${deps.rand."0.6.5".winapi}".default = true; }
    ];
  }) [
    (f: if deps."rand"."0.6.5" ? "rand_os" then recursiveUpdate f { rand_os."${deps."rand"."0.6.5"."rand_os"}"."default" = true; } else f)
    (if deps."rand"."0.6.5" ? "rand_chacha" then features_.rand_chacha."${deps."rand"."0.6.5"."rand_chacha" or ""}" deps else {})
    (if deps."rand"."0.6.5" ? "rand_core" then features_.rand_core."${deps."rand"."0.6.5"."rand_core" or ""}" deps else {})
    (if deps."rand"."0.6.5" ? "rand_hc" then features_.rand_hc."${deps."rand"."0.6.5"."rand_hc" or ""}" deps else {})
    (if deps."rand"."0.6.5" ? "rand_isaac" then features_.rand_isaac."${deps."rand"."0.6.5"."rand_isaac" or ""}" deps else {})
    (if deps."rand"."0.6.5" ? "rand_jitter" then features_.rand_jitter."${deps."rand"."0.6.5"."rand_jitter" or ""}" deps else {})
    (if deps."rand"."0.6.5" ? "rand_os" then features_.rand_os."${deps."rand"."0.6.5"."rand_os" or ""}" deps else {})
    (if deps."rand"."0.6.5" ? "rand_pcg" then features_.rand_pcg."${deps."rand"."0.6.5"."rand_pcg" or ""}" deps else {})
    (if deps."rand"."0.6.5" ? "rand_xorshift" then features_.rand_xorshift."${deps."rand"."0.6.5"."rand_xorshift" or ""}" deps else {})
    (if deps."rand"."0.6.5" ? "autocfg" then features_.autocfg."${deps."rand"."0.6.5"."autocfg" or ""}" deps else {})
    (if deps."rand"."0.6.5" ? "libc" then features_.libc."${deps."rand"."0.6.5"."libc" or ""}" deps else {})
    (if deps."rand"."0.6.5" ? "winapi" then features_.winapi."${deps."rand"."0.6.5"."winapi" or ""}" deps else {})
  ];


# end
# rand_chacha-0.1.1

  crates.rand_chacha."0.1.1" = deps: { features?(features_."rand_chacha"."0.1.1" deps {}) }: buildRustCrate {
    crateName = "rand_chacha";
    version = "0.1.1";
    description = "ChaCha random number generator
";
    homepage = "https://crates.io/crates/rand_chacha";
    authors = [ "The Rand Project Developers" "The Rust Project Developers" ];
    sha256 = "0xnxm4mjd7wjnh18zxc1yickw58axbycp35ciraplqdfwn1gffwi";
    build = "build.rs";
    dependencies = mapFeatures features ([
      (crates."rand_core"."${deps."rand_chacha"."0.1.1"."rand_core"}" deps)
    ]);

    buildDependencies = mapFeatures features ([
      (crates."autocfg"."${deps."rand_chacha"."0.1.1"."autocfg"}" deps)
    ]);
  };
  features_."rand_chacha"."0.1.1" = deps: f: updateFeatures f (rec {
    autocfg."${deps.rand_chacha."0.1.1".autocfg}".default = true;
    rand_chacha."0.1.1".default = (f.rand_chacha."0.1.1".default or true);
    rand_core."${deps.rand_chacha."0.1.1".rand_core}".default = (f.rand_core."${deps.rand_chacha."0.1.1".rand_core}".default or false);
  }) [
    (if deps."rand_chacha"."0.1.1" ? "rand_core" then features_.rand_core."${deps."rand_chacha"."0.1.1"."rand_core" or ""}" deps else {})
    (if deps."rand_chacha"."0.1.1" ? "autocfg" then features_.autocfg."${deps."rand_chacha"."0.1.1"."autocfg" or ""}" deps else {})
  ];


# end
# rand_core-0.3.1

  crates.rand_core."0.3.1" = deps: { features?(features_."rand_core"."0.3.1" deps {}) }: buildRustCrate {
    crateName = "rand_core";
    version = "0.3.1";
    description = "Core random number generator traits and tools for implementation.
";
    homepage = "https://crates.io/crates/rand_core";
    authors = [ "The Rand Project Developers" "The Rust Project Developers" ];
    sha256 = "0q0ssgpj9x5a6fda83nhmfydy7a6c0wvxm0jhncsmjx8qp8gw91m";
    dependencies = mapFeatures features ([
      (crates."rand_core"."${deps."rand_core"."0.3.1"."rand_core"}" deps)
    ]);
    features = mkFeatures (features."rand_core"."0.3.1" or {});
  };
  features_."rand_core"."0.3.1" = deps: f: updateFeatures f (rec {
    rand_core = fold recursiveUpdate {} [
      { "${deps.rand_core."0.3.1".rand_core}"."alloc" =
        (f.rand_core."${deps.rand_core."0.3.1".rand_core}"."alloc" or false) ||
        (rand_core."0.3.1"."alloc" or false) ||
        (f."rand_core"."0.3.1"."alloc" or false); }
      { "${deps.rand_core."0.3.1".rand_core}"."serde1" =
        (f.rand_core."${deps.rand_core."0.3.1".rand_core}"."serde1" or false) ||
        (rand_core."0.3.1"."serde1" or false) ||
        (f."rand_core"."0.3.1"."serde1" or false); }
      { "${deps.rand_core."0.3.1".rand_core}"."std" =
        (f.rand_core."${deps.rand_core."0.3.1".rand_core}"."std" or false) ||
        (rand_core."0.3.1"."std" or false) ||
        (f."rand_core"."0.3.1"."std" or false); }
      { "${deps.rand_core."0.3.1".rand_core}".default = true; }
      { "0.3.1"."std" =
        (f.rand_core."0.3.1"."std" or false) ||
        (f.rand_core."0.3.1"."default" or false) ||
        (rand_core."0.3.1"."default" or false); }
      { "0.3.1".default = (f.rand_core."0.3.1".default or true); }
    ];
  }) [
    (if deps."rand_core"."0.3.1" ? "rand_core" then features_.rand_core."${deps."rand_core"."0.3.1"."rand_core" or ""}" deps else {})
  ];


# end
# rand_core-0.4.0

  crates.rand_core."0.4.0" = deps: { features?(features_."rand_core"."0.4.0" deps {}) }: buildRustCrate {
    crateName = "rand_core";
    version = "0.4.0";
    description = "Core random number generator traits and tools for implementation.
";
    homepage = "https://crates.io/crates/rand_core";
    authors = [ "The Rand Project Developers" "The Rust Project Developers" ];
    sha256 = "0wb5iwhffibj0pnpznhv1g3i7h1fnhz64s3nz74fz6vsm3q6q3br";
    dependencies = mapFeatures features ([
]);
    features = mkFeatures (features."rand_core"."0.4.0" or {});
  };
  features_."rand_core"."0.4.0" = deps: f: updateFeatures f (rec {
    rand_core = fold recursiveUpdate {} [
      { "0.4.0"."alloc" =
        (f.rand_core."0.4.0"."alloc" or false) ||
        (f.rand_core."0.4.0"."std" or false) ||
        (rand_core."0.4.0"."std" or false); }
      { "0.4.0"."serde" =
        (f.rand_core."0.4.0"."serde" or false) ||
        (f.rand_core."0.4.0"."serde1" or false) ||
        (rand_core."0.4.0"."serde1" or false); }
      { "0.4.0"."serde_derive" =
        (f.rand_core."0.4.0"."serde_derive" or false) ||
        (f.rand_core."0.4.0"."serde1" or false) ||
        (rand_core."0.4.0"."serde1" or false); }
      { "0.4.0".default = (f.rand_core."0.4.0".default or true); }
    ];
  }) [];


# end
# rand_hc-0.1.0

  crates.rand_hc."0.1.0" = deps: { features?(features_."rand_hc"."0.1.0" deps {}) }: buildRustCrate {
    crateName = "rand_hc";
    version = "0.1.0";
    description = "HC128 random number generator
";
    homepage = "https://crates.io/crates/rand_hc";
    authors = [ "The Rand Project Developers" ];
    sha256 = "05agb75j87yp7y1zk8yf7bpm66hc0673r3dlypn0kazynr6fdgkz";
    dependencies = mapFeatures features ([
      (crates."rand_core"."${deps."rand_hc"."0.1.0"."rand_core"}" deps)
    ]);
  };
  features_."rand_hc"."0.1.0" = deps: f: updateFeatures f (rec {
    rand_core."${deps.rand_hc."0.1.0".rand_core}".default = (f.rand_core."${deps.rand_hc."0.1.0".rand_core}".default or false);
    rand_hc."0.1.0".default = (f.rand_hc."0.1.0".default or true);
  }) [
    (if deps."rand_hc"."0.1.0" ? "rand_core" then features_.rand_core."${deps."rand_hc"."0.1.0"."rand_core" or ""}" deps else {})
  ];


# end
# rand_isaac-0.1.1

  crates.rand_isaac."0.1.1" = deps: { features?(features_."rand_isaac"."0.1.1" deps {}) }: buildRustCrate {
    crateName = "rand_isaac";
    version = "0.1.1";
    description = "ISAAC random number generator
";
    homepage = "https://crates.io/crates/rand_isaac";
    authors = [ "The Rand Project Developers" "The Rust Project Developers" ];
    sha256 = "10hhdh5b5sa03s6b63y9bafm956jwilx41s71jbrzl63ccx8lxdq";
    dependencies = mapFeatures features ([
      (crates."rand_core"."${deps."rand_isaac"."0.1.1"."rand_core"}" deps)
    ]);
    features = mkFeatures (features."rand_isaac"."0.1.1" or {});
  };
  features_."rand_isaac"."0.1.1" = deps: f: updateFeatures f (rec {
    rand_core = fold recursiveUpdate {} [
      { "${deps.rand_isaac."0.1.1".rand_core}"."serde1" =
        (f.rand_core."${deps.rand_isaac."0.1.1".rand_core}"."serde1" or false) ||
        (rand_isaac."0.1.1"."serde1" or false) ||
        (f."rand_isaac"."0.1.1"."serde1" or false); }
      { "${deps.rand_isaac."0.1.1".rand_core}".default = (f.rand_core."${deps.rand_isaac."0.1.1".rand_core}".default or false); }
    ];
    rand_isaac = fold recursiveUpdate {} [
      { "0.1.1"."serde" =
        (f.rand_isaac."0.1.1"."serde" or false) ||
        (f.rand_isaac."0.1.1"."serde1" or false) ||
        (rand_isaac."0.1.1"."serde1" or false); }
      { "0.1.1"."serde_derive" =
        (f.rand_isaac."0.1.1"."serde_derive" or false) ||
        (f.rand_isaac."0.1.1"."serde1" or false) ||
        (rand_isaac."0.1.1"."serde1" or false); }
      { "0.1.1".default = (f.rand_isaac."0.1.1".default or true); }
    ];
  }) [
    (if deps."rand_isaac"."0.1.1" ? "rand_core" then features_.rand_core."${deps."rand_isaac"."0.1.1"."rand_core" or ""}" deps else {})
  ];


# end
# rand_jitter-0.1.4

  crates.rand_jitter."0.1.4" = deps: { features?(features_."rand_jitter"."0.1.4" deps {}) }: buildRustCrate {
    crateName = "rand_jitter";
    version = "0.1.4";
    description = "Random number generator based on timing jitter";
    authors = [ "The Rand Project Developers" ];
    sha256 = "13nr4h042ab9l7qcv47bxrxw3gkf2pc3cni6c9pyi4nxla0mm7b6";
    dependencies = mapFeatures features ([
      (crates."rand_core"."${deps."rand_jitter"."0.1.4"."rand_core"}" deps)
    ])
      ++ (if kernel == "darwin" || kernel == "ios" then mapFeatures features ([
      (crates."libc"."${deps."rand_jitter"."0.1.4"."libc"}" deps)
    ]) else [])
      ++ (if kernel == "windows" then mapFeatures features ([
      (crates."winapi"."${deps."rand_jitter"."0.1.4"."winapi"}" deps)
    ]) else []);
    features = mkFeatures (features."rand_jitter"."0.1.4" or {});
  };
  features_."rand_jitter"."0.1.4" = deps: f: updateFeatures f (rec {
    libc."${deps.rand_jitter."0.1.4".libc}".default = true;
    rand_core = fold recursiveUpdate {} [
      { "${deps.rand_jitter."0.1.4".rand_core}"."std" =
        (f.rand_core."${deps.rand_jitter."0.1.4".rand_core}"."std" or false) ||
        (rand_jitter."0.1.4"."std" or false) ||
        (f."rand_jitter"."0.1.4"."std" or false); }
      { "${deps.rand_jitter."0.1.4".rand_core}".default = true; }
    ];
    rand_jitter."0.1.4".default = (f.rand_jitter."0.1.4".default or true);
    winapi = fold recursiveUpdate {} [
      { "${deps.rand_jitter."0.1.4".winapi}"."profileapi" = true; }
      { "${deps.rand_jitter."0.1.4".winapi}".default = true; }
    ];
  }) [
    (if deps."rand_jitter"."0.1.4" ? "rand_core" then features_.rand_core."${deps."rand_jitter"."0.1.4"."rand_core" or ""}" deps else {})
    (if deps."rand_jitter"."0.1.4" ? "libc" then features_.libc."${deps."rand_jitter"."0.1.4"."libc" or ""}" deps else {})
    (if deps."rand_jitter"."0.1.4" ? "winapi" then features_.winapi."${deps."rand_jitter"."0.1.4"."winapi" or ""}" deps else {})
  ];


# end
# rand_os-0.1.3

  crates.rand_os."0.1.3" = deps: { features?(features_."rand_os"."0.1.3" deps {}) }: buildRustCrate {
    crateName = "rand_os";
    version = "0.1.3";
    description = "OS backed Random Number Generator";
    homepage = "https://crates.io/crates/rand_os";
    authors = [ "The Rand Project Developers" ];
    sha256 = "0ywwspizgs9g8vzn6m5ix9yg36n15119d6n792h7mk4r5vs0ww4j";
    dependencies = mapFeatures features ([
      (crates."rand_core"."${deps."rand_os"."0.1.3"."rand_core"}" deps)
    ])
      ++ (if abi == "sgx" then mapFeatures features ([
      (crates."rdrand"."${deps."rand_os"."0.1.3"."rdrand"}" deps)
    ]) else [])
      ++ (if kernel == "cloudabi" then mapFeatures features ([
      (crates."cloudabi"."${deps."rand_os"."0.1.3"."cloudabi"}" deps)
    ]) else [])
      ++ (if kernel == "fuchsia" then mapFeatures features ([
      (crates."fuchsia_cprng"."${deps."rand_os"."0.1.3"."fuchsia_cprng"}" deps)
    ]) else [])
      ++ (if (kernel == "linux" || kernel == "darwin") then mapFeatures features ([
      (crates."libc"."${deps."rand_os"."0.1.3"."libc"}" deps)
    ]) else [])
      ++ (if kernel == "windows" then mapFeatures features ([
      (crates."winapi"."${deps."rand_os"."0.1.3"."winapi"}" deps)
    ]) else [])
      ++ (if kernel == "wasm32-unknown-unknown" then mapFeatures features ([
]) else []);
  };
  features_."rand_os"."0.1.3" = deps: f: updateFeatures f (rec {
    cloudabi."${deps.rand_os."0.1.3".cloudabi}".default = true;
    fuchsia_cprng."${deps.rand_os."0.1.3".fuchsia_cprng}".default = true;
    libc."${deps.rand_os."0.1.3".libc}".default = true;
    rand_core = fold recursiveUpdate {} [
      { "${deps.rand_os."0.1.3".rand_core}"."std" = true; }
      { "${deps.rand_os."0.1.3".rand_core}".default = true; }
    ];
    rand_os."0.1.3".default = (f.rand_os."0.1.3".default or true);
    rdrand."${deps.rand_os."0.1.3".rdrand}".default = true;
    winapi = fold recursiveUpdate {} [
      { "${deps.rand_os."0.1.3".winapi}"."minwindef" = true; }
      { "${deps.rand_os."0.1.3".winapi}"."ntsecapi" = true; }
      { "${deps.rand_os."0.1.3".winapi}"."winnt" = true; }
      { "${deps.rand_os."0.1.3".winapi}".default = true; }
    ];
  }) [
    (if deps."rand_os"."0.1.3" ? "rand_core" then features_.rand_core."${deps."rand_os"."0.1.3"."rand_core" or ""}" deps else {})
    (if deps."rand_os"."0.1.3" ? "rdrand" then features_.rdrand."${deps."rand_os"."0.1.3"."rdrand" or ""}" deps else {})
    (if deps."rand_os"."0.1.3" ? "cloudabi" then features_.cloudabi."${deps."rand_os"."0.1.3"."cloudabi" or ""}" deps else {})
    (if deps."rand_os"."0.1.3" ? "fuchsia_cprng" then features_.fuchsia_cprng."${deps."rand_os"."0.1.3"."fuchsia_cprng" or ""}" deps else {})
    (if deps."rand_os"."0.1.3" ? "libc" then features_.libc."${deps."rand_os"."0.1.3"."libc" or ""}" deps else {})
    (if deps."rand_os"."0.1.3" ? "winapi" then features_.winapi."${deps."rand_os"."0.1.3"."winapi" or ""}" deps else {})
  ];


# end
# rand_pcg-0.1.2

  crates.rand_pcg."0.1.2" = deps: { features?(features_."rand_pcg"."0.1.2" deps {}) }: buildRustCrate {
    crateName = "rand_pcg";
    version = "0.1.2";
    description = "Selected PCG random number generators
";
    homepage = "https://crates.io/crates/rand_pcg";
    authors = [ "The Rand Project Developers" ];
    sha256 = "04qgi2ai2z42li5h4aawvxbpnlqyjfnipz9d6k73mdnl6p1xq938";
    build = "build.rs";
    dependencies = mapFeatures features ([
      (crates."rand_core"."${deps."rand_pcg"."0.1.2"."rand_core"}" deps)
    ]);

    buildDependencies = mapFeatures features ([
      (crates."autocfg"."${deps."rand_pcg"."0.1.2"."autocfg"}" deps)
    ]);
    features = mkFeatures (features."rand_pcg"."0.1.2" or {});
  };
  features_."rand_pcg"."0.1.2" = deps: f: updateFeatures f (rec {
    autocfg."${deps.rand_pcg."0.1.2".autocfg}".default = true;
    rand_core."${deps.rand_pcg."0.1.2".rand_core}".default = true;
    rand_pcg = fold recursiveUpdate {} [
      { "0.1.2"."serde" =
        (f.rand_pcg."0.1.2"."serde" or false) ||
        (f.rand_pcg."0.1.2"."serde1" or false) ||
        (rand_pcg."0.1.2"."serde1" or false); }
      { "0.1.2"."serde_derive" =
        (f.rand_pcg."0.1.2"."serde_derive" or false) ||
        (f.rand_pcg."0.1.2"."serde1" or false) ||
        (rand_pcg."0.1.2"."serde1" or false); }
      { "0.1.2".default = (f.rand_pcg."0.1.2".default or true); }
    ];
  }) [
    (if deps."rand_pcg"."0.1.2" ? "rand_core" then features_.rand_core."${deps."rand_pcg"."0.1.2"."rand_core" or ""}" deps else {})
    (if deps."rand_pcg"."0.1.2" ? "autocfg" then features_.autocfg."${deps."rand_pcg"."0.1.2"."autocfg" or ""}" deps else {})
  ];


# end
# rand_xorshift-0.1.1

  crates.rand_xorshift."0.1.1" = deps: { features?(features_."rand_xorshift"."0.1.1" deps {}) }: buildRustCrate {
    crateName = "rand_xorshift";
    version = "0.1.1";
    description = "Xorshift random number generator
";
    homepage = "https://crates.io/crates/rand_xorshift";
    authors = [ "The Rand Project Developers" "The Rust Project Developers" ];
    sha256 = "0v365c4h4lzxwz5k5kp9m0661s0sss7ylv74if0xb4svis9sswnn";
    dependencies = mapFeatures features ([
      (crates."rand_core"."${deps."rand_xorshift"."0.1.1"."rand_core"}" deps)
    ]);
    features = mkFeatures (features."rand_xorshift"."0.1.1" or {});
  };
  features_."rand_xorshift"."0.1.1" = deps: f: updateFeatures f (rec {
    rand_core."${deps.rand_xorshift."0.1.1".rand_core}".default = (f.rand_core."${deps.rand_xorshift."0.1.1".rand_core}".default or false);
    rand_xorshift = fold recursiveUpdate {} [
      { "0.1.1"."serde" =
        (f.rand_xorshift."0.1.1"."serde" or false) ||
        (f.rand_xorshift."0.1.1"."serde1" or false) ||
        (rand_xorshift."0.1.1"."serde1" or false); }
      { "0.1.1"."serde_derive" =
        (f.rand_xorshift."0.1.1"."serde_derive" or false) ||
        (f.rand_xorshift."0.1.1"."serde1" or false) ||
        (rand_xorshift."0.1.1"."serde1" or false); }
      { "0.1.1".default = (f.rand_xorshift."0.1.1".default or true); }
    ];
  }) [
    (if deps."rand_xorshift"."0.1.1" ? "rand_core" then features_.rand_core."${deps."rand_xorshift"."0.1.1"."rand_core" or ""}" deps else {})
  ];


# end
# rawpointer-0.1.0

  crates.rawpointer."0.1.0" = deps: { features?(features_."rawpointer"."0.1.0" deps {}) }: buildRustCrate {
    crateName = "rawpointer";
    version = "0.1.0";
    description = "Extra methods for raw pointers.

For example `.post_inc()` and `.pre_dec()` (c.f. `ptr++` and `--ptr`) and
`ptrdistance`.
";
    authors = [ "bluss" ];
    sha256 = "0hblv2cv310ixf5f1jw4nk9w5pb95wh4dwqyjv07g2xrshbw6j04";
  };
  features_."rawpointer"."0.1.0" = deps: f: updateFeatures f (rec {
    rawpointer."0.1.0".default = (f.rawpointer."0.1.0".default or true);
  }) [];


# end
# rayon-1.1.0

  crates.rayon."1.1.0" = deps: { features?(features_."rayon"."1.1.0" deps {}) }: buildRustCrate {
    crateName = "rayon";
    version = "1.1.0";
    description = "Simple work-stealing parallelism for Rust";
    authors = [ "Niko Matsakis <niko@alum.mit.edu>" "Josh Stone <cuviper@gmail.com>" ];
    sha256 = "07984mgfdkv8zfg8b9wvjssfhm8wz1x9ls2lc9dfmbjv7kmfag4l";
    dependencies = mapFeatures features ([
      (crates."crossbeam_deque"."${deps."rayon"."1.1.0"."crossbeam_deque"}" deps)
      (crates."either"."${deps."rayon"."1.1.0"."either"}" deps)
      (crates."rayon_core"."${deps."rayon"."1.1.0"."rayon_core"}" deps)
    ]);
  };
  features_."rayon"."1.1.0" = deps: f: updateFeatures f (rec {
    crossbeam_deque."${deps.rayon."1.1.0".crossbeam_deque}".default = true;
    either."${deps.rayon."1.1.0".either}".default = (f.either."${deps.rayon."1.1.0".either}".default or false);
    rayon."1.1.0".default = (f.rayon."1.1.0".default or true);
    rayon_core."${deps.rayon."1.1.0".rayon_core}".default = true;
  }) [
    (if deps."rayon"."1.1.0" ? "crossbeam_deque" then features_.crossbeam_deque."${deps."rayon"."1.1.0"."crossbeam_deque" or ""}" deps else {})
    (if deps."rayon"."1.1.0" ? "either" then features_.either."${deps."rayon"."1.1.0"."either" or ""}" deps else {})
    (if deps."rayon"."1.1.0" ? "rayon_core" then features_.rayon_core."${deps."rayon"."1.1.0"."rayon_core" or ""}" deps else {})
  ];


# end
# rayon-core-1.5.0

  crates.rayon_core."1.5.0" = deps: { features?(features_."rayon_core"."1.5.0" deps {}) }: buildRustCrate {
    crateName = "rayon-core";
    version = "1.5.0";
    description = "Core APIs for Rayon";
    authors = [ "Niko Matsakis <niko@alum.mit.edu>" "Josh Stone <cuviper@gmail.com>" ];
    sha256 = "1aarjhj57dppxz3b2rvwdxvq47464sm84423vpwjm9yll8pc2ac7";
    build = "build.rs";
    dependencies = mapFeatures features ([
      (crates."crossbeam_deque"."${deps."rayon_core"."1.5.0"."crossbeam_deque"}" deps)
      (crates."crossbeam_queue"."${deps."rayon_core"."1.5.0"."crossbeam_queue"}" deps)
      (crates."crossbeam_utils"."${deps."rayon_core"."1.5.0"."crossbeam_utils"}" deps)
      (crates."lazy_static"."${deps."rayon_core"."1.5.0"."lazy_static"}" deps)
      (crates."num_cpus"."${deps."rayon_core"."1.5.0"."num_cpus"}" deps)
    ])
      ++ (if (kernel == "linux" || kernel == "darwin") then mapFeatures features ([
]) else []);
  };
  features_."rayon_core"."1.5.0" = deps: f: updateFeatures f (rec {
    crossbeam_deque."${deps.rayon_core."1.5.0".crossbeam_deque}".default = true;
    crossbeam_queue."${deps.rayon_core."1.5.0".crossbeam_queue}".default = true;
    crossbeam_utils."${deps.rayon_core."1.5.0".crossbeam_utils}".default = true;
    lazy_static."${deps.rayon_core."1.5.0".lazy_static}".default = true;
    num_cpus."${deps.rayon_core."1.5.0".num_cpus}".default = true;
    rayon_core."1.5.0".default = (f.rayon_core."1.5.0".default or true);
  }) [
    (if deps."rayon_core"."1.5.0" ? "crossbeam_deque" then features_.crossbeam_deque."${deps."rayon_core"."1.5.0"."crossbeam_deque" or ""}" deps else {})
    (if deps."rayon_core"."1.5.0" ? "crossbeam_queue" then features_.crossbeam_queue."${deps."rayon_core"."1.5.0"."crossbeam_queue" or ""}" deps else {})
    (if deps."rayon_core"."1.5.0" ? "crossbeam_utils" then features_.crossbeam_utils."${deps."rayon_core"."1.5.0"."crossbeam_utils" or ""}" deps else {})
    (if deps."rayon_core"."1.5.0" ? "lazy_static" then features_.lazy_static."${deps."rayon_core"."1.5.0"."lazy_static" or ""}" deps else {})
    (if deps."rayon_core"."1.5.0" ? "num_cpus" then features_.num_cpus."${deps."rayon_core"."1.5.0"."num_cpus" or ""}" deps else {})
  ];


# end
# rdrand-0.4.0

  crates.rdrand."0.4.0" = deps: { features?(features_."rdrand"."0.4.0" deps {}) }: buildRustCrate {
    crateName = "rdrand";
    version = "0.4.0";
    description = "An implementation of random number generator based on rdrand and rdseed instructions";
    authors = [ "Simonas Kazlauskas <rdrand@kazlauskas.me>" ];
    sha256 = "15hrcasn0v876wpkwab1dwbk9kvqwrb3iv4y4dibb6yxnfvzwajk";
    dependencies = mapFeatures features ([
      (crates."rand_core"."${deps."rdrand"."0.4.0"."rand_core"}" deps)
    ]);
    features = mkFeatures (features."rdrand"."0.4.0" or {});
  };
  features_."rdrand"."0.4.0" = deps: f: updateFeatures f (rec {
    rand_core."${deps.rdrand."0.4.0".rand_core}".default = (f.rand_core."${deps.rdrand."0.4.0".rand_core}".default or false);
    rdrand = fold recursiveUpdate {} [
      { "0.4.0"."std" =
        (f.rdrand."0.4.0"."std" or false) ||
        (f.rdrand."0.4.0"."default" or false) ||
        (rdrand."0.4.0"."default" or false); }
      { "0.4.0".default = (f.rdrand."0.4.0".default or true); }
    ];
  }) [
    (if deps."rdrand"."0.4.0" ? "rand_core" then features_.rand_core."${deps."rdrand"."0.4.0"."rand_core" or ""}" deps else {})
  ];


# end
# reductive-0.2.0

  crates.reductive."0.2.0" = deps: { features?(features_."reductive"."0.2.0" deps {}) }: buildRustCrate {
    crateName = "reductive";
    version = "0.2.0";
    description = "Optimized vector quantization for dense vectors";
    homepage = "https://git.sr.ht/~danieldk/reductive";
    authors = [ "Daniël de Kok <me@danieldk.eu>" ];
    edition = "2018";
    sha256 = "0pca4j30lbbzfiimgkj2m0gdmidjzqkjvbxn0m9fdl46w7xgqhik";
    dependencies = mapFeatures features ([
      (crates."log"."${deps."reductive"."0.2.0"."log"}" deps)
      (crates."ndarray"."${deps."reductive"."0.2.0"."ndarray"}" deps)
      (crates."ndarray_parallel"."${deps."reductive"."0.2.0"."ndarray_parallel"}" deps)
      (crates."num_traits"."${deps."reductive"."0.2.0"."num_traits"}" deps)
      (crates."ordered_float"."${deps."reductive"."0.2.0"."ordered_float"}" deps)
      (crates."rand"."${deps."reductive"."0.2.0"."rand"}" deps)
      (crates."rand_xorshift"."${deps."reductive"."0.2.0"."rand_xorshift"}" deps)
      (crates."rayon"."${deps."reductive"."0.2.0"."rayon"}" deps)
    ]);
    features = mkFeatures (features."reductive"."0.2.0" or {});
  };
  features_."reductive"."0.2.0" = deps: f: updateFeatures f (rec {
    log."${deps.reductive."0.2.0".log}".default = true;
    ndarray."${deps.reductive."0.2.0".ndarray}".default = true;
    ndarray_parallel."${deps.reductive."0.2.0".ndarray_parallel}".default = true;
    num_traits."${deps.reductive."0.2.0".num_traits}".default = true;
    ordered_float."${deps.reductive."0.2.0".ordered_float}".default = true;
    rand."${deps.reductive."0.2.0".rand}".default = true;
    rand_xorshift."${deps.reductive."0.2.0".rand_xorshift}".default = true;
    rayon."${deps.reductive."0.2.0".rayon}".default = true;
    reductive = fold recursiveUpdate {} [
      { "0.2.0"."ndarray-linalg" =
        (f.reductive."0.2.0"."ndarray-linalg" or false) ||
        (f.reductive."0.2.0"."opq-train" or false) ||
        (reductive."0.2.0"."opq-train" or false); }
      { "0.2.0".default = (f.reductive."0.2.0".default or true); }
    ];
  }) [
    (if deps."reductive"."0.2.0" ? "log" then features_.log."${deps."reductive"."0.2.0"."log" or ""}" deps else {})
    (if deps."reductive"."0.2.0" ? "ndarray" then features_.ndarray."${deps."reductive"."0.2.0"."ndarray" or ""}" deps else {})
    (if deps."reductive"."0.2.0" ? "ndarray_parallel" then features_.ndarray_parallel."${deps."reductive"."0.2.0"."ndarray_parallel" or ""}" deps else {})
    (if deps."reductive"."0.2.0" ? "num_traits" then features_.num_traits."${deps."reductive"."0.2.0"."num_traits" or ""}" deps else {})
    (if deps."reductive"."0.2.0" ? "ordered_float" then features_.ordered_float."${deps."reductive"."0.2.0"."ordered_float" or ""}" deps else {})
    (if deps."reductive"."0.2.0" ? "rand" then features_.rand."${deps."reductive"."0.2.0"."rand" or ""}" deps else {})
    (if deps."reductive"."0.2.0" ? "rand_xorshift" then features_.rand_xorshift."${deps."reductive"."0.2.0"."rand_xorshift" or ""}" deps else {})
    (if deps."reductive"."0.2.0" ? "rayon" then features_.rayon."${deps."reductive"."0.2.0"."rayon" or ""}" deps else {})
  ];


# end
# regex-1.3.1

  crates.regex."1.3.1" = deps: { features?(features_."regex"."1.3.1" deps {}) }: buildRustCrate {
    crateName = "regex";
    version = "1.3.1";
    description = "An implementation of regular expressions for Rust. This implementation uses
finite automata and guarantees linear time matching on all inputs.
";
    homepage = "https://github.com/rust-lang/regex";
    authors = [ "The Rust Project Developers" ];
    sha256 = "0508b01q7iwky5gzp1cc3lpz6al1qam8skgcvkfgxr67nikiz7jn";
    dependencies = mapFeatures features ([
      (crates."regex_syntax"."${deps."regex"."1.3.1"."regex_syntax"}" deps)
    ]
      ++ (if features.regex."1.3.1".aho-corasick or false then [ (crates.aho_corasick."${deps."regex"."1.3.1".aho_corasick}" deps) ] else [])
      ++ (if features.regex."1.3.1".memchr or false then [ (crates.memchr."${deps."regex"."1.3.1".memchr}" deps) ] else [])
      ++ (if features.regex."1.3.1".thread_local or false then [ (crates.thread_local."${deps."regex"."1.3.1".thread_local}" deps) ] else []));
    features = mkFeatures (features."regex"."1.3.1" or {});
  };
  features_."regex"."1.3.1" = deps: f: updateFeatures f (rec {
    regex = fold recursiveUpdate {} [
      { "1.3.1"."aho-corasick" =
        (f.regex."1.3.1"."aho-corasick" or false) ||
        (f.regex."1.3.1"."perf-literal" or false) ||
        (regex."1.3.1"."perf-literal" or false); }
      { "1.3.1"."memchr" =
        (f.regex."1.3.1"."memchr" or false) ||
        (f.regex."1.3.1"."perf-literal" or false) ||
        (regex."1.3.1"."perf-literal" or false); }
      { "1.3.1"."pattern" =
        (f.regex."1.3.1"."pattern" or false) ||
        (f.regex."1.3.1"."unstable" or false) ||
        (regex."1.3.1"."unstable" or false); }
      { "1.3.1"."perf" =
        (f.regex."1.3.1"."perf" or false) ||
        (f.regex."1.3.1"."default" or false) ||
        (regex."1.3.1"."default" or false); }
      { "1.3.1"."perf-cache" =
        (f.regex."1.3.1"."perf-cache" or false) ||
        (f.regex."1.3.1"."perf" or false) ||
        (regex."1.3.1"."perf" or false); }
      { "1.3.1"."perf-dfa" =
        (f.regex."1.3.1"."perf-dfa" or false) ||
        (f.regex."1.3.1"."perf" or false) ||
        (regex."1.3.1"."perf" or false); }
      { "1.3.1"."perf-inline" =
        (f.regex."1.3.1"."perf-inline" or false) ||
        (f.regex."1.3.1"."perf" or false) ||
        (regex."1.3.1"."perf" or false); }
      { "1.3.1"."perf-literal" =
        (f.regex."1.3.1"."perf-literal" or false) ||
        (f.regex."1.3.1"."perf" or false) ||
        (regex."1.3.1"."perf" or false); }
      { "1.3.1"."std" =
        (f.regex."1.3.1"."std" or false) ||
        (f.regex."1.3.1"."default" or false) ||
        (regex."1.3.1"."default" or false) ||
        (f.regex."1.3.1"."use_std" or false) ||
        (regex."1.3.1"."use_std" or false); }
      { "1.3.1"."thread_local" =
        (f.regex."1.3.1"."thread_local" or false) ||
        (f.regex."1.3.1"."perf-cache" or false) ||
        (regex."1.3.1"."perf-cache" or false); }
      { "1.3.1"."unicode" =
        (f.regex."1.3.1"."unicode" or false) ||
        (f.regex."1.3.1"."default" or false) ||
        (regex."1.3.1"."default" or false); }
      { "1.3.1"."unicode-age" =
        (f.regex."1.3.1"."unicode-age" or false) ||
        (f.regex."1.3.1"."unicode" or false) ||
        (regex."1.3.1"."unicode" or false); }
      { "1.3.1"."unicode-bool" =
        (f.regex."1.3.1"."unicode-bool" or false) ||
        (f.regex."1.3.1"."unicode" or false) ||
        (regex."1.3.1"."unicode" or false); }
      { "1.3.1"."unicode-case" =
        (f.regex."1.3.1"."unicode-case" or false) ||
        (f.regex."1.3.1"."unicode" or false) ||
        (regex."1.3.1"."unicode" or false); }
      { "1.3.1"."unicode-gencat" =
        (f.regex."1.3.1"."unicode-gencat" or false) ||
        (f.regex."1.3.1"."unicode" or false) ||
        (regex."1.3.1"."unicode" or false); }
      { "1.3.1"."unicode-perl" =
        (f.regex."1.3.1"."unicode-perl" or false) ||
        (f.regex."1.3.1"."unicode" or false) ||
        (regex."1.3.1"."unicode" or false); }
      { "1.3.1"."unicode-script" =
        (f.regex."1.3.1"."unicode-script" or false) ||
        (f.regex."1.3.1"."unicode" or false) ||
        (regex."1.3.1"."unicode" or false); }
      { "1.3.1"."unicode-segment" =
        (f.regex."1.3.1"."unicode-segment" or false) ||
        (f.regex."1.3.1"."unicode" or false) ||
        (regex."1.3.1"."unicode" or false); }
      { "1.3.1".default = (f.regex."1.3.1".default or true); }
    ];
    regex_syntax = fold recursiveUpdate {} [
      { "${deps.regex."1.3.1".regex_syntax}"."unicode-age" =
        (f.regex_syntax."${deps.regex."1.3.1".regex_syntax}"."unicode-age" or false) ||
        (regex."1.3.1"."unicode-age" or false) ||
        (f."regex"."1.3.1"."unicode-age" or false); }
      { "${deps.regex."1.3.1".regex_syntax}"."unicode-bool" =
        (f.regex_syntax."${deps.regex."1.3.1".regex_syntax}"."unicode-bool" or false) ||
        (regex."1.3.1"."unicode-bool" or false) ||
        (f."regex"."1.3.1"."unicode-bool" or false); }
      { "${deps.regex."1.3.1".regex_syntax}"."unicode-case" =
        (f.regex_syntax."${deps.regex."1.3.1".regex_syntax}"."unicode-case" or false) ||
        (regex."1.3.1"."unicode-case" or false) ||
        (f."regex"."1.3.1"."unicode-case" or false); }
      { "${deps.regex."1.3.1".regex_syntax}"."unicode-gencat" =
        (f.regex_syntax."${deps.regex."1.3.1".regex_syntax}"."unicode-gencat" or false) ||
        (regex."1.3.1"."unicode-gencat" or false) ||
        (f."regex"."1.3.1"."unicode-gencat" or false); }
      { "${deps.regex."1.3.1".regex_syntax}"."unicode-perl" =
        (f.regex_syntax."${deps.regex."1.3.1".regex_syntax}"."unicode-perl" or false) ||
        (regex."1.3.1"."unicode-perl" or false) ||
        (f."regex"."1.3.1"."unicode-perl" or false); }
      { "${deps.regex."1.3.1".regex_syntax}"."unicode-script" =
        (f.regex_syntax."${deps.regex."1.3.1".regex_syntax}"."unicode-script" or false) ||
        (regex."1.3.1"."unicode-script" or false) ||
        (f."regex"."1.3.1"."unicode-script" or false); }
      { "${deps.regex."1.3.1".regex_syntax}"."unicode-segment" =
        (f.regex_syntax."${deps.regex."1.3.1".regex_syntax}"."unicode-segment" or false) ||
        (regex."1.3.1"."unicode-segment" or false) ||
        (f."regex"."1.3.1"."unicode-segment" or false); }
      { "${deps.regex."1.3.1".regex_syntax}".default = (f.regex_syntax."${deps.regex."1.3.1".regex_syntax}".default or false); }
    ];
  }) [
    (f: if deps."regex"."1.3.1" ? "aho_corasick" then recursiveUpdate f { aho_corasick."${deps."regex"."1.3.1"."aho_corasick"}"."default" = true; } else f)
    (f: if deps."regex"."1.3.1" ? "memchr" then recursiveUpdate f { memchr."${deps."regex"."1.3.1"."memchr"}"."default" = true; } else f)
    (f: if deps."regex"."1.3.1" ? "thread_local" then recursiveUpdate f { thread_local."${deps."regex"."1.3.1"."thread_local"}"."default" = true; } else f)
    (if deps."regex"."1.3.1" ? "aho_corasick" then features_.aho_corasick."${deps."regex"."1.3.1"."aho_corasick" or ""}" deps else {})
    (if deps."regex"."1.3.1" ? "memchr" then features_.memchr."${deps."regex"."1.3.1"."memchr" or ""}" deps else {})
    (if deps."regex"."1.3.1" ? "regex_syntax" then features_.regex_syntax."${deps."regex"."1.3.1"."regex_syntax" or ""}" deps else {})
    (if deps."regex"."1.3.1" ? "thread_local" then features_.thread_local."${deps."regex"."1.3.1"."thread_local" or ""}" deps else {})
  ];


# end
# regex-syntax-0.6.12

  crates.regex_syntax."0.6.12" = deps: { features?(features_."regex_syntax"."0.6.12" deps {}) }: buildRustCrate {
    crateName = "regex-syntax";
    version = "0.6.12";
    description = "A regular expression parser.";
    homepage = "https://github.com/rust-lang/regex";
    authors = [ "The Rust Project Developers" ];
    sha256 = "1lqhddhwzpgq8zfkxhm241n7g4m3yc11fb4098dkgawbxvybr53v";
    features = mkFeatures (features."regex_syntax"."0.6.12" or {});
  };
  features_."regex_syntax"."0.6.12" = deps: f: updateFeatures f (rec {
    regex_syntax = fold recursiveUpdate {} [
      { "0.6.12"."unicode" =
        (f.regex_syntax."0.6.12"."unicode" or false) ||
        (f.regex_syntax."0.6.12"."default" or false) ||
        (regex_syntax."0.6.12"."default" or false); }
      { "0.6.12"."unicode-age" =
        (f.regex_syntax."0.6.12"."unicode-age" or false) ||
        (f.regex_syntax."0.6.12"."unicode" or false) ||
        (regex_syntax."0.6.12"."unicode" or false); }
      { "0.6.12"."unicode-bool" =
        (f.regex_syntax."0.6.12"."unicode-bool" or false) ||
        (f.regex_syntax."0.6.12"."unicode" or false) ||
        (regex_syntax."0.6.12"."unicode" or false); }
      { "0.6.12"."unicode-case" =
        (f.regex_syntax."0.6.12"."unicode-case" or false) ||
        (f.regex_syntax."0.6.12"."unicode" or false) ||
        (regex_syntax."0.6.12"."unicode" or false); }
      { "0.6.12"."unicode-gencat" =
        (f.regex_syntax."0.6.12"."unicode-gencat" or false) ||
        (f.regex_syntax."0.6.12"."unicode" or false) ||
        (regex_syntax."0.6.12"."unicode" or false); }
      { "0.6.12"."unicode-perl" =
        (f.regex_syntax."0.6.12"."unicode-perl" or false) ||
        (f.regex_syntax."0.6.12"."unicode" or false) ||
        (regex_syntax."0.6.12"."unicode" or false); }
      { "0.6.12"."unicode-script" =
        (f.regex_syntax."0.6.12"."unicode-script" or false) ||
        (f.regex_syntax."0.6.12"."unicode" or false) ||
        (regex_syntax."0.6.12"."unicode" or false); }
      { "0.6.12"."unicode-segment" =
        (f.regex_syntax."0.6.12"."unicode-segment" or false) ||
        (f.regex_syntax."0.6.12"."unicode" or false) ||
        (regex_syntax."0.6.12"."unicode" or false); }
      { "0.6.12".default = (f.regex_syntax."0.6.12".default or true); }
    ];
  }) [];


# end
# rustc-demangle-0.1.15

  crates.rustc_demangle."0.1.15" = deps: { features?(features_."rustc_demangle"."0.1.15" deps {}) }: buildRustCrate {
    crateName = "rustc-demangle";
    version = "0.1.15";
    description = "Rust compiler symbol demangling.
";
    homepage = "https://github.com/alexcrichton/rustc-demangle";
    authors = [ "Alex Crichton <alex@alexcrichton.com>" ];
    sha256 = "04rgsfzhz4k9s56vkczsdbvmvg9409xp0nw4cy99lb2i0aa0255s";
    dependencies = mapFeatures features ([
]);
    features = mkFeatures (features."rustc_demangle"."0.1.15" or {});
  };
  features_."rustc_demangle"."0.1.15" = deps: f: updateFeatures f (rec {
    rustc_demangle = fold recursiveUpdate {} [
      { "0.1.15"."compiler_builtins" =
        (f.rustc_demangle."0.1.15"."compiler_builtins" or false) ||
        (f.rustc_demangle."0.1.15"."rustc-dep-of-std" or false) ||
        (rustc_demangle."0.1.15"."rustc-dep-of-std" or false); }
      { "0.1.15"."core" =
        (f.rustc_demangle."0.1.15"."core" or false) ||
        (f.rustc_demangle."0.1.15"."rustc-dep-of-std" or false) ||
        (rustc_demangle."0.1.15"."rustc-dep-of-std" or false); }
      { "0.1.15".default = (f.rustc_demangle."0.1.15".default or true); }
    ];
  }) [];


# end
# ryu-1.0.0

  crates.ryu."1.0.0" = deps: { features?(features_."ryu"."1.0.0" deps {}) }: buildRustCrate {
    crateName = "ryu";
    version = "1.0.0";
    description = "Fast floating point to string conversion";
    authors = [ "David Tolnay <dtolnay@gmail.com>" ];
    sha256 = "0hysqba7hi31xw1jka8jh7qb4m9fx5l6vik55wpc3rpsg46cwgbf";
    build = "build.rs";
    dependencies = mapFeatures features ([
]);
    features = mkFeatures (features."ryu"."1.0.0" or {});
  };
  features_."ryu"."1.0.0" = deps: f: updateFeatures f (rec {
    ryu."1.0.0".default = (f.ryu."1.0.0".default or true);
  }) [];


# end
# scopeguard-0.3.3

  crates.scopeguard."0.3.3" = deps: { features?(features_."scopeguard"."0.3.3" deps {}) }: buildRustCrate {
    crateName = "scopeguard";
    version = "0.3.3";
    description = "A RAII scope guard that will run a given closure when it goes out of scope,
even if the code between panics (assuming unwinding panic).

Defines the macros `defer!` and `defer_on_unwind!`; the latter only runs
if the scope is extited through unwinding on panic.
";
    authors = [ "bluss" ];
    sha256 = "0i1l013csrqzfz6c68pr5pi01hg5v5yahq8fsdmaxy6p8ygsjf3r";
    features = mkFeatures (features."scopeguard"."0.3.3" or {});
  };
  features_."scopeguard"."0.3.3" = deps: f: updateFeatures f (rec {
    scopeguard = fold recursiveUpdate {} [
      { "0.3.3"."use_std" =
        (f.scopeguard."0.3.3"."use_std" or false) ||
        (f.scopeguard."0.3.3"."default" or false) ||
        (scopeguard."0.3.3"."default" or false); }
      { "0.3.3".default = (f.scopeguard."0.3.3".default or true); }
    ];
  }) [];


# end
# serde-1.0.99

  crates.serde."1.0.99" = deps: { features?(features_."serde"."1.0.99" deps {}) }: buildRustCrate {
    crateName = "serde";
    version = "1.0.99";
    description = "A generic serialization/deserialization framework";
    homepage = "https://serde.rs";
    authors = [ "Erick Tryzelaar <erick.tryzelaar@gmail.com>" "David Tolnay <dtolnay@gmail.com>" ];
    sha256 = "1wwj6rv8h7k1sc0s8b8jcwcr54ayg46zjfv8z9a59hgnzg17nr86";
    build = "build.rs";
    dependencies = mapFeatures features ([
    ]
      ++ (if features.serde."1.0.99".serde_derive or false then [ (crates.serde_derive."${deps."serde"."1.0.99".serde_derive}" deps) ] else []));
    features = mkFeatures (features."serde"."1.0.99" or {});
  };
  features_."serde"."1.0.99" = deps: f: updateFeatures f (rec {
    serde = fold recursiveUpdate {} [
      { "1.0.99"."serde_derive" =
        (f.serde."1.0.99"."serde_derive" or false) ||
        (f.serde."1.0.99"."derive" or false) ||
        (serde."1.0.99"."derive" or false); }
      { "1.0.99"."std" =
        (f.serde."1.0.99"."std" or false) ||
        (f.serde."1.0.99"."default" or false) ||
        (serde."1.0.99"."default" or false); }
      { "1.0.99".default = (f.serde."1.0.99".default or true); }
    ];
  }) [
    (f: if deps."serde"."1.0.99" ? "serde_derive" then recursiveUpdate f { serde_derive."${deps."serde"."1.0.99"."serde_derive"}"."default" = true; } else f)
    (if deps."serde"."1.0.99" ? "serde_derive" then features_.serde_derive."${deps."serde"."1.0.99"."serde_derive" or ""}" deps else {})
  ];


# end
# serde_derive-1.0.98

  crates.serde_derive."1.0.98" = deps: { features?(features_."serde_derive"."1.0.98" deps {}) }: buildRustCrate {
    crateName = "serde_derive";
    version = "1.0.98";
    description = "Macros 1.1 implementation of #[derive(Serialize, Deserialize)]";
    homepage = "https://serde.rs";
    authors = [ "Erick Tryzelaar <erick.tryzelaar@gmail.com>" "David Tolnay <dtolnay@gmail.com>" ];
    sha256 = "0yk3850f0rbsaqrv0a4x7mqsfkpfipbxas45vv03sfdmxvpwcrvg";
    procMacro = true;
    dependencies = mapFeatures features ([
      (crates."proc_macro2"."${deps."serde_derive"."1.0.98"."proc_macro2"}" deps)
      (crates."quote"."${deps."serde_derive"."1.0.98"."quote"}" deps)
      (crates."syn"."${deps."serde_derive"."1.0.98"."syn"}" deps)
    ]);
    features = mkFeatures (features."serde_derive"."1.0.98" or {});
  };
  features_."serde_derive"."1.0.98" = deps: f: updateFeatures f (rec {
    proc_macro2."${deps.serde_derive."1.0.98".proc_macro2}".default = true;
    quote."${deps.serde_derive."1.0.98".quote}".default = true;
    serde_derive."1.0.98".default = (f.serde_derive."1.0.98".default or true);
    syn = fold recursiveUpdate {} [
      { "${deps.serde_derive."1.0.98".syn}"."visit" = true; }
      { "${deps.serde_derive."1.0.98".syn}".default = true; }
    ];
  }) [
    (if deps."serde_derive"."1.0.98" ? "proc_macro2" then features_.proc_macro2."${deps."serde_derive"."1.0.98"."proc_macro2" or ""}" deps else {})
    (if deps."serde_derive"."1.0.98" ? "quote" then features_.quote."${deps."serde_derive"."1.0.98"."quote" or ""}" deps else {})
    (if deps."serde_derive"."1.0.98" ? "syn" then features_.syn."${deps."serde_derive"."1.0.98"."syn" or ""}" deps else {})
  ];


# end
# serde_json-1.0.40

  crates.serde_json."1.0.40" = deps: { features?(features_."serde_json"."1.0.40" deps {}) }: buildRustCrate {
    crateName = "serde_json";
    version = "1.0.40";
    description = "A JSON serialization file format";
    authors = [ "Erick Tryzelaar <erick.tryzelaar@gmail.com>" "David Tolnay <dtolnay@gmail.com>" ];
    sha256 = "1wf8lkisjvyg4ghp2fwm3ysymjy66l030l8d7p6033wiayfzpyh3";
    dependencies = mapFeatures features ([
      (crates."itoa"."${deps."serde_json"."1.0.40"."itoa"}" deps)
      (crates."ryu"."${deps."serde_json"."1.0.40"."ryu"}" deps)
      (crates."serde"."${deps."serde_json"."1.0.40"."serde"}" deps)
    ]);
    features = mkFeatures (features."serde_json"."1.0.40" or {});
  };
  features_."serde_json"."1.0.40" = deps: f: updateFeatures f (rec {
    itoa."${deps.serde_json."1.0.40".itoa}".default = true;
    ryu."${deps.serde_json."1.0.40".ryu}".default = true;
    serde."${deps.serde_json."1.0.40".serde}".default = true;
    serde_json = fold recursiveUpdate {} [
      { "1.0.40"."indexmap" =
        (f.serde_json."1.0.40"."indexmap" or false) ||
        (f.serde_json."1.0.40"."preserve_order" or false) ||
        (serde_json."1.0.40"."preserve_order" or false); }
      { "1.0.40".default = (f.serde_json."1.0.40".default or true); }
    ];
  }) [
    (if deps."serde_json"."1.0.40" ? "itoa" then features_.itoa."${deps."serde_json"."1.0.40"."itoa" or ""}" deps else {})
    (if deps."serde_json"."1.0.40" ? "ryu" then features_.ryu."${deps."serde_json"."1.0.40"."ryu" or ""}" deps else {})
    (if deps."serde_json"."1.0.40" ? "serde" then features_.serde."${deps."serde_json"."1.0.40"."serde" or ""}" deps else {})
  ];


# end
# spin-0.5.2

  crates.spin."0.5.2" = deps: { features?(features_."spin"."0.5.2" deps {}) }: buildRustCrate {
    crateName = "spin";
    version = "0.5.2";
    description = "Synchronization primitives based on spinning.
They may contain data, are usable without `std`,
and static initializers are available.
";
    authors = [ "Mathijs van de Nes <git@mathijs.vd-nes.nl>" "John Ericson <git@JohnEricson.me>" ];
    sha256 = "1x0mfk6jfxknrp833xq97kzqxidlryndn0v3xkwf4pd7l9hr5k4h";
  };
  features_."spin"."0.5.2" = deps: f: updateFeatures f (rec {
    spin."0.5.2".default = (f.spin."0.5.2".default or true);
  }) [];


# end
# syn-0.15.42

  crates.syn."0.15.42" = deps: { features?(features_."syn"."0.15.42" deps {}) }: buildRustCrate {
    crateName = "syn";
    version = "0.15.42";
    description = "Parser for Rust source code";
    authors = [ "David Tolnay <dtolnay@gmail.com>" ];
    sha256 = "0yjvq4izrsp6pvpahr86m1mq09nbq6a27fizkmg76xh8fhwfpd79";
    dependencies = mapFeatures features ([
      (crates."proc_macro2"."${deps."syn"."0.15.42"."proc_macro2"}" deps)
      (crates."unicode_xid"."${deps."syn"."0.15.42"."unicode_xid"}" deps)
    ]
      ++ (if features.syn."0.15.42".quote or false then [ (crates.quote."${deps."syn"."0.15.42".quote}" deps) ] else []));
    features = mkFeatures (features."syn"."0.15.42" or {});
  };
  features_."syn"."0.15.42" = deps: f: updateFeatures f (rec {
    proc_macro2 = fold recursiveUpdate {} [
      { "${deps.syn."0.15.42".proc_macro2}"."proc-macro" =
        (f.proc_macro2."${deps.syn."0.15.42".proc_macro2}"."proc-macro" or false) ||
        (syn."0.15.42"."proc-macro" or false) ||
        (f."syn"."0.15.42"."proc-macro" or false); }
      { "${deps.syn."0.15.42".proc_macro2}".default = (f.proc_macro2."${deps.syn."0.15.42".proc_macro2}".default or false); }
    ];
    quote."${deps.syn."0.15.42".quote}"."proc-macro" =
        (f.quote."${deps.syn."0.15.42".quote}"."proc-macro" or false) ||
        (syn."0.15.42"."proc-macro" or false) ||
        (f."syn"."0.15.42"."proc-macro" or false);
    syn = fold recursiveUpdate {} [
      { "0.15.42"."clone-impls" =
        (f.syn."0.15.42"."clone-impls" or false) ||
        (f.syn."0.15.42"."default" or false) ||
        (syn."0.15.42"."default" or false); }
      { "0.15.42"."derive" =
        (f.syn."0.15.42"."derive" or false) ||
        (f.syn."0.15.42"."default" or false) ||
        (syn."0.15.42"."default" or false); }
      { "0.15.42"."parsing" =
        (f.syn."0.15.42"."parsing" or false) ||
        (f.syn."0.15.42"."default" or false) ||
        (syn."0.15.42"."default" or false); }
      { "0.15.42"."printing" =
        (f.syn."0.15.42"."printing" or false) ||
        (f.syn."0.15.42"."default" or false) ||
        (syn."0.15.42"."default" or false); }
      { "0.15.42"."proc-macro" =
        (f.syn."0.15.42"."proc-macro" or false) ||
        (f.syn."0.15.42"."default" or false) ||
        (syn."0.15.42"."default" or false); }
      { "0.15.42"."quote" =
        (f.syn."0.15.42"."quote" or false) ||
        (f.syn."0.15.42"."printing" or false) ||
        (syn."0.15.42"."printing" or false); }
      { "0.15.42".default = (f.syn."0.15.42".default or true); }
    ];
    unicode_xid."${deps.syn."0.15.42".unicode_xid}".default = true;
  }) [
    (f: if deps."syn"."0.15.42" ? "quote" then recursiveUpdate f { quote."${deps."syn"."0.15.42"."quote"}"."default" = false; } else f)
    (if deps."syn"."0.15.42" ? "proc_macro2" then features_.proc_macro2."${deps."syn"."0.15.42"."proc_macro2" or ""}" deps else {})
    (if deps."syn"."0.15.42" ? "quote" then features_.quote."${deps."syn"."0.15.42"."quote" or ""}" deps else {})
    (if deps."syn"."0.15.42" ? "unicode_xid" then features_.unicode_xid."${deps."syn"."0.15.42"."unicode_xid" or ""}" deps else {})
  ];


# end
# syn-1.0.5

  crates.syn."1.0.5" = deps: { features?(features_."syn"."1.0.5" deps {}) }: buildRustCrate {
    crateName = "syn";
    version = "1.0.5";
    description = "Parser for Rust source code";
    authors = [ "David Tolnay <dtolnay@gmail.com>" ];
    edition = "2018";
    sha256 = "08qbk425r8c4q4rrpq1q9wkd3v3bji8nlfaxj8v4l7lkpjkh0xgs";
    dependencies = mapFeatures features ([
      (crates."proc_macro2"."${deps."syn"."1.0.5"."proc_macro2"}" deps)
      (crates."unicode_xid"."${deps."syn"."1.0.5"."unicode_xid"}" deps)
    ]
      ++ (if features.syn."1.0.5".quote or false then [ (crates.quote."${deps."syn"."1.0.5".quote}" deps) ] else []));
    features = mkFeatures (features."syn"."1.0.5" or {});
  };
  features_."syn"."1.0.5" = deps: f: updateFeatures f (rec {
    proc_macro2 = fold recursiveUpdate {} [
      { "${deps.syn."1.0.5".proc_macro2}"."proc-macro" =
        (f.proc_macro2."${deps.syn."1.0.5".proc_macro2}"."proc-macro" or false) ||
        (syn."1.0.5"."proc-macro" or false) ||
        (f."syn"."1.0.5"."proc-macro" or false); }
      { "${deps.syn."1.0.5".proc_macro2}".default = (f.proc_macro2."${deps.syn."1.0.5".proc_macro2}".default or false); }
    ];
    quote."${deps.syn."1.0.5".quote}"."proc-macro" =
        (f.quote."${deps.syn."1.0.5".quote}"."proc-macro" or false) ||
        (syn."1.0.5"."proc-macro" or false) ||
        (f."syn"."1.0.5"."proc-macro" or false);
    syn = fold recursiveUpdate {} [
      { "1.0.5"."clone-impls" =
        (f.syn."1.0.5"."clone-impls" or false) ||
        (f.syn."1.0.5"."default" or false) ||
        (syn."1.0.5"."default" or false); }
      { "1.0.5"."derive" =
        (f.syn."1.0.5"."derive" or false) ||
        (f.syn."1.0.5"."default" or false) ||
        (syn."1.0.5"."default" or false); }
      { "1.0.5"."parsing" =
        (f.syn."1.0.5"."parsing" or false) ||
        (f.syn."1.0.5"."default" or false) ||
        (syn."1.0.5"."default" or false); }
      { "1.0.5"."printing" =
        (f.syn."1.0.5"."printing" or false) ||
        (f.syn."1.0.5"."default" or false) ||
        (syn."1.0.5"."default" or false); }
      { "1.0.5"."proc-macro" =
        (f.syn."1.0.5"."proc-macro" or false) ||
        (f.syn."1.0.5"."default" or false) ||
        (syn."1.0.5"."default" or false); }
      { "1.0.5"."quote" =
        (f.syn."1.0.5"."quote" or false) ||
        (f.syn."1.0.5"."printing" or false) ||
        (syn."1.0.5"."printing" or false); }
      { "1.0.5".default = (f.syn."1.0.5".default or true); }
    ];
    unicode_xid."${deps.syn."1.0.5".unicode_xid}".default = true;
  }) [
    (f: if deps."syn"."1.0.5" ? "quote" then recursiveUpdate f { quote."${deps."syn"."1.0.5"."quote"}"."default" = false; } else f)
    (if deps."syn"."1.0.5" ? "proc_macro2" then features_.proc_macro2."${deps."syn"."1.0.5"."proc_macro2" or ""}" deps else {})
    (if deps."syn"."1.0.5" ? "quote" then features_.quote."${deps."syn"."1.0.5"."quote" or ""}" deps else {})
    (if deps."syn"."1.0.5" ? "unicode_xid" then features_.unicode_xid."${deps."syn"."1.0.5"."unicode_xid" or ""}" deps else {})
  ];


# end
# synstructure-0.10.2

  crates.synstructure."0.10.2" = deps: { features?(features_."synstructure"."0.10.2" deps {}) }: buildRustCrate {
    crateName = "synstructure";
    version = "0.10.2";
    description = "Helper methods and macros for custom derives";
    authors = [ "Nika Layzell <nika@thelayzells.com>" ];
    sha256 = "0bp29grjsim99xm1l6h38mbl98gnk47lf82rawlmws5zn4asdpj4";
    dependencies = mapFeatures features ([
      (crates."proc_macro2"."${deps."synstructure"."0.10.2"."proc_macro2"}" deps)
      (crates."quote"."${deps."synstructure"."0.10.2"."quote"}" deps)
      (crates."syn"."${deps."synstructure"."0.10.2"."syn"}" deps)
      (crates."unicode_xid"."${deps."synstructure"."0.10.2"."unicode_xid"}" deps)
    ]);
    features = mkFeatures (features."synstructure"."0.10.2" or {});
  };
  features_."synstructure"."0.10.2" = deps: f: updateFeatures f (rec {
    proc_macro2."${deps.synstructure."0.10.2".proc_macro2}".default = true;
    quote."${deps.synstructure."0.10.2".quote}".default = true;
    syn = fold recursiveUpdate {} [
      { "${deps.synstructure."0.10.2".syn}"."extra-traits" = true; }
      { "${deps.synstructure."0.10.2".syn}"."visit" = true; }
      { "${deps.synstructure."0.10.2".syn}".default = true; }
    ];
    synstructure."0.10.2".default = (f.synstructure."0.10.2".default or true);
    unicode_xid."${deps.synstructure."0.10.2".unicode_xid}".default = true;
  }) [
    (if deps."synstructure"."0.10.2" ? "proc_macro2" then features_.proc_macro2."${deps."synstructure"."0.10.2"."proc_macro2" or ""}" deps else {})
    (if deps."synstructure"."0.10.2" ? "quote" then features_.quote."${deps."synstructure"."0.10.2"."quote" or ""}" deps else {})
    (if deps."synstructure"."0.10.2" ? "syn" then features_.syn."${deps."synstructure"."0.10.2"."syn" or ""}" deps else {})
    (if deps."synstructure"."0.10.2" ? "unicode_xid" then features_.unicode_xid."${deps."synstructure"."0.10.2"."unicode_xid" or ""}" deps else {})
  ];


# end
# thread_local-0.3.6

  crates.thread_local."0.3.6" = deps: { features?(features_."thread_local"."0.3.6" deps {}) }: buildRustCrate {
    crateName = "thread_local";
    version = "0.3.6";
    description = "Per-object thread-local storage";
    authors = [ "Amanieu d'Antras <amanieu@gmail.com>" ];
    sha256 = "02rksdwjmz2pw9bmgbb4c0bgkbq5z6nvg510sq1s6y2j1gam0c7i";
    dependencies = mapFeatures features ([
      (crates."lazy_static"."${deps."thread_local"."0.3.6"."lazy_static"}" deps)
    ]);
  };
  features_."thread_local"."0.3.6" = deps: f: updateFeatures f (rec {
    lazy_static."${deps.thread_local."0.3.6".lazy_static}".default = true;
    thread_local."0.3.6".default = (f.thread_local."0.3.6".default or true);
  }) [
    (if deps."thread_local"."0.3.6" ? "lazy_static" then features_.lazy_static."${deps."thread_local"."0.3.6"."lazy_static" or ""}" deps else {})
  ];


# end
# toml-0.5.1

  crates.toml."0.5.1" = deps: { features?(features_."toml"."0.5.1" deps {}) }: buildRustCrate {
    crateName = "toml";
    version = "0.5.1";
    description = "A native Rust encoder and decoder of TOML-formatted files and streams. Provides
implementations of the standard Serialize/Deserialize traits for TOML data to
facilitate deserializing and serializing Rust structures.
";
    homepage = "https://github.com/alexcrichton/toml-rs";
    authors = [ "Alex Crichton <alex@alexcrichton.com>" ];
    edition = "2018";
    sha256 = "1878ifdh576viwqg80vnhm51bng96vhyfi20jk8fv6wcifhgl4dg";
    dependencies = mapFeatures features ([
      (crates."serde"."${deps."toml"."0.5.1"."serde"}" deps)
    ]);
    features = mkFeatures (features."toml"."0.5.1" or {});
  };
  features_."toml"."0.5.1" = deps: f: updateFeatures f (rec {
    serde."${deps.toml."0.5.1".serde}".default = true;
    toml = fold recursiveUpdate {} [
      { "0.5.1"."linked-hash-map" =
        (f.toml."0.5.1"."linked-hash-map" or false) ||
        (f.toml."0.5.1"."preserve_order" or false) ||
        (toml."0.5.1"."preserve_order" or false); }
      { "0.5.1".default = (f.toml."0.5.1".default or true); }
    ];
  }) [
    (if deps."toml"."0.5.1" ? "serde" then features_.serde."${deps."toml"."0.5.1"."serde" or ""}" deps else {})
  ];


# end
# unicode-xid-0.1.0

  crates.unicode_xid."0.1.0" = deps: { features?(features_."unicode_xid"."0.1.0" deps {}) }: buildRustCrate {
    crateName = "unicode-xid";
    version = "0.1.0";
    description = "Determine whether characters have the XID_Start
or XID_Continue properties according to
Unicode Standard Annex #31.
";
    homepage = "https://github.com/unicode-rs/unicode-xid";
    authors = [ "erick.tryzelaar <erick.tryzelaar@gmail.com>" "kwantam <kwantam@gmail.com>" ];
    sha256 = "05wdmwlfzxhq3nhsxn6wx4q8dhxzzfb9szsz6wiw092m1rjj01zj";
    features = mkFeatures (features."unicode_xid"."0.1.0" or {});
  };
  features_."unicode_xid"."0.1.0" = deps: f: updateFeatures f (rec {
    unicode_xid."0.1.0".default = (f.unicode_xid."0.1.0".default or true);
  }) [];


# end
# unicode-xid-0.2.0

  crates.unicode_xid."0.2.0" = deps: { features?(features_."unicode_xid"."0.2.0" deps {}) }: buildRustCrate {
    crateName = "unicode-xid";
    version = "0.2.0";
    description = "Determine whether characters have the XID_Start
or XID_Continue properties according to
Unicode Standard Annex #31.
";
    homepage = "https://github.com/unicode-rs/unicode-xid";
    authors = [ "erick.tryzelaar <erick.tryzelaar@gmail.com>" "kwantam <kwantam@gmail.com>" ];
    sha256 = "1c85gb3p3qhbjvfyjb31m06la4f024jx319k10ig7n47dz2fk8v7";
    features = mkFeatures (features."unicode_xid"."0.2.0" or {});
  };
  features_."unicode_xid"."0.2.0" = deps: f: updateFeatures f (rec {
    unicode_xid."0.2.0".default = (f.unicode_xid."0.2.0".default or true);
  }) [];


# end
# unindent-0.1.4

  crates.unindent."0.1.4" = deps: { features?(features_."unindent"."0.1.4" deps {}) }: buildRustCrate {
    crateName = "unindent";
    version = "0.1.4";
    description = "Remove a column of leading whitespace from a string";
    authors = [ "David Tolnay <dtolnay@gmail.com>" ];
    edition = "2018";
    sha256 = "0sjmwba80xydjpr9adhnsay7fbfrw406kkxln710ihrasxsk8889";
  };
  features_."unindent"."0.1.4" = deps: f: updateFeatures f (rec {
    unindent."0.1.4".default = (f.unindent."0.1.4".default or true);
  }) [];


# end
# version_check-0.9.1

  crates.version_check."0.9.1" = deps: { features?(features_."version_check"."0.9.1" deps {}) }: buildRustCrate {
    crateName = "version_check";
    version = "0.9.1";
    description = "Tiny crate to check the version of the installed/running rustc.";
    authors = [ "Sergio Benitez <sb@sergio.bz>" ];
    sha256 = "00aywbaicdi81gcxpqdz6g0l96885bz4bml5c9xfna5p01vrh4li";
  };
  features_."version_check"."0.9.1" = deps: f: updateFeatures f (rec {
    version_check."0.9.1".default = (f.version_check."0.9.1".default or true);
  }) [];


# end
# winapi-0.3.7

  crates.winapi."0.3.7" = deps: { features?(features_."winapi"."0.3.7" deps {}) }: buildRustCrate {
    crateName = "winapi";
    version = "0.3.7";
    description = "Raw FFI bindings for all of Windows API.";
    authors = [ "Peter Atashian <retep998@gmail.com>" ];
    sha256 = "1k51gfkp0zqw7nj07y443mscs46icmdhld442s2073niap0kkdr8";
    build = "build.rs";
    dependencies = (if kernel == "i686-pc-windows-gnu" then mapFeatures features ([
      (crates."winapi_i686_pc_windows_gnu"."${deps."winapi"."0.3.7"."winapi_i686_pc_windows_gnu"}" deps)
    ]) else [])
      ++ (if kernel == "x86_64-pc-windows-gnu" then mapFeatures features ([
      (crates."winapi_x86_64_pc_windows_gnu"."${deps."winapi"."0.3.7"."winapi_x86_64_pc_windows_gnu"}" deps)
    ]) else []);
    features = mkFeatures (features."winapi"."0.3.7" or {});
  };
  features_."winapi"."0.3.7" = deps: f: updateFeatures f (rec {
    winapi = fold recursiveUpdate {} [
      { "0.3.7"."impl-debug" =
        (f.winapi."0.3.7"."impl-debug" or false) ||
        (f.winapi."0.3.7"."debug" or false) ||
        (winapi."0.3.7"."debug" or false); }
      { "0.3.7".default = (f.winapi."0.3.7".default or true); }
    ];
    winapi_i686_pc_windows_gnu."${deps.winapi."0.3.7".winapi_i686_pc_windows_gnu}".default = true;
    winapi_x86_64_pc_windows_gnu."${deps.winapi."0.3.7".winapi_x86_64_pc_windows_gnu}".default = true;
  }) [
    (if deps."winapi"."0.3.7" ? "winapi_i686_pc_windows_gnu" then features_.winapi_i686_pc_windows_gnu."${deps."winapi"."0.3.7"."winapi_i686_pc_windows_gnu" or ""}" deps else {})
    (if deps."winapi"."0.3.7" ? "winapi_x86_64_pc_windows_gnu" then features_.winapi_x86_64_pc_windows_gnu."${deps."winapi"."0.3.7"."winapi_x86_64_pc_windows_gnu" or ""}" deps else {})
  ];


# end
# winapi-i686-pc-windows-gnu-0.4.0

  crates.winapi_i686_pc_windows_gnu."0.4.0" = deps: { features?(features_."winapi_i686_pc_windows_gnu"."0.4.0" deps {}) }: buildRustCrate {
    crateName = "winapi-i686-pc-windows-gnu";
    version = "0.4.0";
    description = "Import libraries for the i686-pc-windows-gnu target. Please don't use this crate directly, depend on winapi instead.";
    authors = [ "Peter Atashian <retep998@gmail.com>" ];
    sha256 = "05ihkij18r4gamjpxj4gra24514can762imjzlmak5wlzidplzrp";
    build = "build.rs";
  };
  features_."winapi_i686_pc_windows_gnu"."0.4.0" = deps: f: updateFeatures f (rec {
    winapi_i686_pc_windows_gnu."0.4.0".default = (f.winapi_i686_pc_windows_gnu."0.4.0".default or true);
  }) [];


# end
# winapi-x86_64-pc-windows-gnu-0.4.0

  crates.winapi_x86_64_pc_windows_gnu."0.4.0" = deps: { features?(features_."winapi_x86_64_pc_windows_gnu"."0.4.0" deps {}) }: buildRustCrate {
    crateName = "winapi-x86_64-pc-windows-gnu";
    version = "0.4.0";
    description = "Import libraries for the x86_64-pc-windows-gnu target. Please don't use this crate directly, depend on winapi instead.";
    authors = [ "Peter Atashian <retep998@gmail.com>" ];
    sha256 = "0n1ylmlsb8yg1v583i4xy0qmqg42275flvbc51hdqjjfjcl9vlbj";
    build = "build.rs";
  };
  features_."winapi_x86_64_pc_windows_gnu"."0.4.0" = deps: f: updateFeatures f (rec {
    winapi_x86_64_pc_windows_gnu."0.4.0".default = (f.winapi_x86_64_pc_windows_gnu."0.4.0".default or true);
  }) [];


# end
}
