_: {
  flake = {
    # Home-manager modules
    homeManagerModules = {
      default = ./home-manager;
      tidalcycles = ./home-manager/tidalcycles.nix;
      supercollider = ./home-manager/supercollider.nix;
      superdirt = ./home-manager/superdirt.nix;
    };

    # NixOS modules (optional system-level config)
    nixosModules = {
      default = ./nixos;
      audio = ./nixos/audio.nix;
    };
  };
}
