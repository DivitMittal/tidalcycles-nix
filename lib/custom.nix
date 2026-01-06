{lib}: let
  # Scan a directory and import all .nix files
  scanPaths = path:
    builtins.map
    (f: (path + "/${f}"))
    (
      builtins.attrNames
      (
        lib.attrsets.filterAttrs
        (
          path: _type:
            (_type == "directory") || (path != "default.nix" && lib.strings.hasSuffix ".nix" path)
        )
        (builtins.readDir path)
      )
    );
in {
  inherit scanPaths;

  # Import all files from a directory
  importAll = path: lib.attrsets.genAttrs (scanPaths path) import;

  # Make a boot script with custom parameters
  mkBootScript = {
    pkgs,
    profile ? "standard",
    customScript ? null,
  }: let
    profileScript =
      if customScript != null
      then builtins.readFile customScript
      else builtins.readFile (../packages/boot-scripts/profiles + "/${profile}.hs");
  in
    pkgs.writeText "BootTidal.hs" profileScript;
}
