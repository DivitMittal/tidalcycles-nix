_: {
  flake = {
    # Pre-configured profiles
    profiles = {
      minimal = import ./profiles/minimal.nix;
      standard = import ./profiles/standard.nix;
      performance = import ./profiles/performance.nix;
      studio = import ./profiles/studio.nix;
    };
  };
}
