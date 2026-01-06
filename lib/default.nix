{lib}: {
  custom = import ./custom.nix {inherit lib;};
  types = import ./types.nix {inherit lib;};
}
