{inputs, ...}: {
  imports = [inputs.git-hooks.flakeModule];

  perSystem = _: {
    checks = {
      # Treefmt provides its own check via treefmt.build.check
    };

    pre-commit.settings.hooks = {
      alejandra.enable = true;
      deadnix.enable = true;
      statix.enable = true;
    };
  };
}
