_: {
  flake = {
    # Pre-configured profiles
    profiles = {
      minimal = import ./minimal.nix;
      standard = import ./standard.nix;
      performance = import ./performance.nix;
      studio = import ./studio.nix;
    };
  };
}
