# Minimal TidalCycles profile
# Suitable for beginners or low-resource systems
{
  programs.tidalcycles = {
    enable = true;

    boot = {
      profile = "minimal";
      orbits = 8;
    };

    supercollider = {
      enable = true;

      serverOptions = {
        numBuffers = 1024 * 128;
        memSize = 8192 * 16;
        maxNodes = 1024 * 16;
      };
    };

    superdirt = {
      enable = true;
      profile = "minimal";
      quarks = ["SuperDirt"];
    };

    helpers.installScripts = true;

    development = {
      enableGhc = true;
      enableCabal = false;
      enableStack = false;
    };
  };
}
