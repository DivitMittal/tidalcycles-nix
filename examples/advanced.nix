# Advanced TidalCycles configuration example
# Demonstrates all major features
{pkgs, ...}: {
  programs.tidalcycles = {
    enable = true;

    # Extended boot script with custom functions
    boot = {
      profile = "extended";
      orbits = 16;
      frameTimespan = 1.0 / 30.0; # Higher precision timing
      connection = {
        address = "127.0.0.1";
        port = 57120;
        latency = 0.05; # Lower latency for tighter timing
      };

      extraImports = [
        "qualified Data.Map as Map"
        "Control.Monad"
      ];

      extraFunctions = ''
        -- Custom helper functions
        fastPattern = fast 4 . (# speed 1.2)
        slowPattern = slow 2 . (# speed 0.8)

        -- Custom transition
        myTransition i t = transition tidal True (Sound.Tidal.Transition.xfadeIn t) i
      '';
    };

    # Performance-tuned SuperCollider
    supercollider = {
      enable = true;

      serverOptions = {
        numBuffers = 1024 * 512; # Double the default
        memSize = 8192 * 64; # 4x default memory
        numWireBufs = 256;
        maxNodes = 1024 * 64;
        numOutputBusChannels = 8; # Multi-channel output
        numInputBusChannels = 4;
        sampleRate = 48000;
        blockSize = 64;
      };
    };

    # Advanced SuperDirt with extra quarks
    superdirt = {
      enable = true;
      profile = "advanced";

      quarks = [
        "SuperDirt"
        "Vowel"
        "VSTPlugin"
      ];

      extraSampleDirs = [
        "$HOME/Music/samples"
      ];

      extraConfig = ''
        // Custom audio routing
        ~dirt.orbits.do { |orbit, i|
          orbit.outBus = (i * 2) % ~dirt.numChannels;
        };

        // Add global effects
        ~dirt.orbits[0].setGlobalEffects([\\distortion, \\reverb]);

        "Custom SuperDirt configuration loaded".postln;
      '';
    };

    # MIDI integration
    midi = {
      enable = true;

      devices = [
        {
          name = "MIDI Fighter Twister";
          channels = 16;
          latency = 0.1;
        }
        {
          name = "Elektron Digitakt";
          channels = 8;
          latency = 0.05;
        }
      ];
    };

    # OSC for visuals
    osc = {
      enable = true;

      targets = [
        {
          name = "resolume";
          address = "127.0.0.1";
          port = 7000;
        }
        {
          name = "touchdesigner";
          address = "192.168.1.100";
          port = 8000;
        }
      ];
    };

    # Editor integration
    editor = {
      vim.enable = true;
      # emacs.enable = true;
      # vscode.enable = true;
    };

    # Development tools
    development = {
      enableGhc = true;
      enableCabal = true;

      extraHaskellPackages = with pkgs.haskellPackages; [
        lens
        vector
        aeson
      ];
    };

    # Helper scripts
    helpers = {
      installScripts = true;
      wrapSclang = true;
    };
  };
}
