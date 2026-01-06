{
  description = "A comprehensive NixOS/home-manager module for TidalCycles live coding";

  outputs = {
    nixpkgs,
    flake-parts,
    ...
  } @ inputs: let
    lib = nixpkgs.lib.extend (final: _super: {
      tidalcycles = import ./lib {lib = final;};
    });
  in
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];

      imports = [
        ./flake/devshells.nix
        ./flake/formatters.nix
        ./flake/checks.nix
        ./flake/packages.nix
      ];

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

        # Pre-configured profiles
        profiles = {
          minimal = import ./profiles/minimal.nix;
          standard = import ./profiles/standard.nix;
          performance = import ./profiles/performance.nix;
          studio = import ./profiles/studio.nix;
        };

        # Overlay for custom packages
        overlays.default = final: _prev: {
          tidalcycles-scripts = final.callPackage ./packages {};
        };

        # Custom lib
        lib = lib.tidalcycles;
      };
    };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
