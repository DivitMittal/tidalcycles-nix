# Standard TidalCycles profile
# Recommended for most users
{
  programs.tidalcycles = {
    enable = true;

    boot = {
      profile = "standard";
      orbits = 12;
    };

    supercollider = {
      enable = true;

      serverOptions = {
        numBuffers = 1024 * 256;
        memSize = 8192 * 32;
        maxNodes = 1024 * 32;
      };
    };

    superdirt = {
      enable = true;
      profile = "standard";
      quarks = ["SuperDirt" "Vowel"];
    };

    helpers = {
      installScripts = true;
      wrapSclang = true;
    };

    development = {
      enableGhc = true;
      enableCabal = false;
      enableStack = false;
    };
  };
}
