# Studio TidalCycles profile
# Full featured with MIDI, OSC, and editor integration
{pkgs, ...}: {
  programs.tidalcycles = {
    enable = true;

    boot = {
      profile = "extended";
      orbits = 12;
    };

    supercollider = {
      enable = true;

      serverOptions = {
        numBuffers = 1024 * 512;
        memSize = 8192 * 64;
        maxNodes = 1024 * 64;
        numOutputBusChannels = 8;
        numInputBusChannels = 4;
      };
    };

    superdirt = {
      enable = true;
      profile = "advanced";
      quarks = ["SuperDirt" "Vowel" "VSTPlugin"];
    };

    midi = {
      enable = true;
      # Configure your MIDI devices here
      devices = [];
    };

    osc = {
      enable = true;
      # Configure your OSC targets here
      targets = [];
    };

    editor = {
      vim.enable = true;
      # Enable your preferred editor
      # emacs.enable = true;
      # vscode.enable = true;
    };

    helpers = {
      installScripts = true;
      wrapSclang = true;
    };

    development = {
      enableGhc = true;
      enableCabal = true;
      enableStack = false;

      extraHaskellPackages = with pkgs.haskellPackages; [
        lens
        vector
      ];
    };
  };
}
