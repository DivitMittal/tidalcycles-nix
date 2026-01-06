_: {
  flake = {
    # Home-manager modules
    homeManagerModules = {
      default = ./modules/home-manager;
      tidalcycles = ./modules/home-manager/tidalcycles.nix;
      supercollider = ./modules/home-manager/supercollider.nix;
      superdirt = ./modules/home-manager/superdirt.nix;
    };

    # NixOS modules (optional system-level config)
    nixosModules = {
      default = ./modules/nixos;
      audio = ./modules/nixos/audio.nix;
    };
  };
}
