{ version

# top-level dependencies
, stdenv
, lib

# build-time deps
, haskell, ghcPackage ? "ghc844"
, automake
, autoconf
, bash
, bison
, flex
, perl
, verilog
, pkgconfig

# runtime deps
, zlib
, gmp
, gperf
, libpoly
, libX11
, fontconfig
, xorg
, glibc
}:

let
  gmp-static = gmp.override { withStatic = true; };

  ghcWithPackages = haskell.packages."${ghcPackage}".ghc.withPackages (g: with g; [
    old-time regex-compat syb
  ]);

in stdenv.mkDerivation {
  pname = "bsc";
  inherit version;
  src = lib.cleanSource ./.;

  # enableParallelBuilding = true;

  buildInputs = [
    zlib
    gmp-static gperf libpoly # yices
    libX11 # tcltk
    xorg.libXft
    fontconfig
  ];

  nativeBuildInputs = [
    automake autoconf
    perl
    pkgconfig
    flex
    bison
    ghcWithPackages
    glibc.bin
  ];

  checkInputs = [
    verilog
  ];

  preBuild = ''
    patchShebangs src/Verilog/copy_module.pl
    patchShebangs src/stp/src/AST/genkinds.pl
    patchShebangs src/comp/update-build-version.sh
    patchShebangs src/comp/update-build-system.sh
    patchShebangs src/comp/wrapper.sh
  '';

  makeFlags = [
    "NOGIT=1" # https://github.com/B-Lang-org/bsc/issues/12
  ];

  installPhase = "mv inst $out";

  doCheck = true;
}
