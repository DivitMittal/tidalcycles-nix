{inputs, ...}: let
  # Create tidalcycles namespace by importing custom utilities and types
  mkTidalcyclesLib = lib: {
    custom = import ./custom.nix {inherit lib;};
    types = import ./types.nix {inherit lib;};
  };

  # Extend nixpkgs lib with our custom utilities
  extendedLib = inputs.nixpkgs.lib.extend (final: _super: {
    tidalcycles = mkTidalcyclesLib final;
  });
in {
  flake = {
    # Export custom lib
    lib = extendedLib.tidalcycles;
  };
}
