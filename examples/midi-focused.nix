# MIDI-focused TidalCycles configuration
# Optimized for controlling hardware synths and drum machines
{
  programs.tidalcycles = {
    enable = true;

    boot = {
      profile = "midi";
      orbits = 8; # Fewer orbits, more MIDI channels

      connection = {
        address = "127.0.0.1";
        port = 57120;
        latency = 0.1;
      };
    };

    supercollider = {
      enable = true;

      serverOptions = {
        # Standard settings sufficient for MIDI
        numBuffers = 1024 * 256;
        memSize = 8192 * 32;
      };
    };

    superdirt = {
      enable = true;
      profile = "minimal"; # Don't need extensive audio samples
    };

    midi = {
      enable = true;

      devices = [
        {
          name = "Elektron Digitakt";
          channels = 8;
          latency = 0.05;
        }
        {
          name = "Elektron Analog Four";
          channels = 4;
          latency = 0.05;
        }
        {
          name = "Arturia DrumBrute";
          channels = 1;
          latency = 0.1;
        }
        {
          name = "MIDI Fighter Twister";
          channels = 16;
          latency = 0.1;
        }
      ];
    };

    editor.vim.enable = true;

    development = {
      enableGhc = true;
      enableCabal = false;
      enableStack = false;
    };
  };
}
