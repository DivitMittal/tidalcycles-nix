_: {
  flake = {
    # Home-manager modules
    homeManagerModules = {
      default = ./home-manager/tidalcycles.nix;
      tidalcycles = ./home-manager/tidalcycles.nix;
    };

    # NixOS modules (optional system-level config)
    nixosModules = {
      default = ./nixos/audio.nix;
      audio = ./nixos/audio.nix;
    };
  };
}
