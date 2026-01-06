# Performance TidalCycles profile
# Optimized for complex patterns and live performance
{
  programs.tidalcycles = {
    enable = true;

    boot = {
      profile = "extended";
      orbits = 16;
      frameTimespan = 1.0 / 30.0; # Higher precision
      connection = {
        latency = 0.05; # Lower latency
      };
    };

    supercollider = {
      enable = true;

      serverOptions = {
        numBuffers = 1024 * 512;
        memSize = 8192 * 64;
        numWireBufs = 256;
        maxNodes = 1024 * 64;
        numOutputBusChannels = 8;
        numInputBusChannels = 4;
        sampleRate = 48000;
        blockSize = 64;
      };
    };

    superdirt = {
      enable = true;
      profile = "advanced";
      quarks = ["SuperDirt" "Vowel" "VSTPlugin"];
    };

    helpers = {
      installScripts = true;
      wrapSclang = true;
    };

    development = {
      enableGhc = true;
      enableCabal = true;
      enableStack = false;
    };
  };
}
