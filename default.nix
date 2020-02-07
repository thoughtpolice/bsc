{ repo ? builtins.fetchGit ./.
, versionFile ? ./.version
, officialRelease ? false

, nixpkgs ? null
, config ? {}
, system ? builtins.currentSystem
}:

with builtins;

let
  bootstrap = import ./src/nix/bootstrap.nix {
    inherit nixpkgs config system;
    inherit repo officialRelease versionFile;
  };
in

with bootstrap.pkgs;

(callPackage ./bsc.nix { inherit (bootstrap) version; })
