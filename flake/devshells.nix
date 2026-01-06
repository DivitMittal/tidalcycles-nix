{inputs, ...}: {
  imports = [inputs.devshell.flakeModule];

  perSystem = {pkgs, ...}: {
    devShells.default = pkgs.mkShell {
      buildInputs = with pkgs; [
        alejandra
        nil
        statix
        deadnix
      ];

      shellHook = ''
        echo "TidalCycles-Nix development environment"
        echo "Run 'nix fmt' to format Nix files"
        echo "Run 'nix flake check' to run checks"
      '';
    };
  };
}
