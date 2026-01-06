{
  lib,
  ...
}: let
  # Custom library for scanning directories
  customLib = import ../lib/custom.nix {inherit lib;};
in {
  # Auto-import all flake modules using scanPaths
  imports = customLib.scanPaths ./.;
}
