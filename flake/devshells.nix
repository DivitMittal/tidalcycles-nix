{
  inputs,
  lib,
  ...
}: {
  imports = [inputs.devshell.flakeModule];

  perSystem = {
    pkgs,
    config,
    ...
  }: {
    devshells.default = {
      devshell = rec {
        name = "tidalcycles-nix";
        motd = "{202}Welcome to {91}${name} {202}devshell!{reset} \n $(menu)";
        startup = {
          git-hooks.text = ''
            ${config.pre-commit.installationScript}
          '';
        };
        packages = lib.attrsets.attrValues {
          inherit
            (pkgs)
            ### LSPs & Formatters
            ## Nix
            nixd
            alejandra
            ;
          ## AI context. apm-cli isn't in nixpkgs-26.05-darwin (x86_64-darwin);
          ## run the same PyPI release (microsoft/apm) ephemerally via uv there.
          apm-cli =
            pkgs.apm-cli or (pkgs.writeShellScriptBin "apm" ''
              exec ${pkgs.uv}/bin/uv tool run --from apm-cli apm "$@"
            '');
        };
      };
    };
  };
}
