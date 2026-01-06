{inputs, ...}: let
  # Extend nixpkgs lib with our custom utilities
  extendedLib = inputs.nixpkgs.lib.extend (final: _super: {
    tidalcycles = import ../lib {lib = final;};
  });
in {
  flake = {
    # Export custom lib
    lib = extendedLib.tidalcycles;
  };
}
