# TidalCycles Home Manager Module

A comprehensive home-manager module for TidalCycles live coding environment, providing declarative configuration for TidalCycles, SuperCollider, and SuperDirt.

## Features

- **Complete TidalCycles Setup**: Install and configure TidalCycles with sensible defaults
- **SuperCollider Integration**: Automatic SuperCollider configuration with optimized server settings
- **SuperDirt Configuration**: Multiple profiles (minimal, standard, advanced) with customization options
- **Helper Scripts**: Convenient commands for installation and management
- **MIDI Support**: Configure MIDI devices with per-device latency settings
- **OSC Support**: Send patterns to external OSC targets
- **Editor Integration**: Optional integration with Vim/Neovim, Emacs, and VS Code
- **Platform Aware**: Handles macOS and Linux differences automatically
- **Sample Pack Management**: Declarative sample pack installation

## Quick Start

### Basic Configuration

```nix
{
  programs.tidalcycles = {
    enable = true;
  };
}
```

This minimal configuration will:
- Install TidalCycles with the standard boot script
- Install SuperCollider
- Configure SuperDirt with 12 orbits
- Provide helper scripts for installation and startup

### After Installation

1. Install SuperDirt quarks:
   ```bash
   install-superdirt
   ```

2. Start SuperDirt (in one terminal):
   ```bash
   start-superdirt
   ```

3. Start Tidal REPL (in another terminal):
   ```bash
   tidal-repl
   ```

## Configuration Options

### Boot Configuration

Control how TidalCycles starts and connects to SuperDirt:

```nix
{
  programs.tidalcycles = {
    enable = true;

    boot = {
      # Choose a profile: minimal, standard, extended, midi
      profile = "standard";

      # Or use a custom boot script
      customScript = ./my-boot.hs;

      # Connection settings
      connection = {
        address = "127.0.0.1";
        port = 57120;
        latency = 0.1;
      };

      # Number of audio orbits
      orbits = 12;

      # Frame timing (lower = more precise, higher CPU)
      frameTimespan = 1.0 / 20.0;

      # Additional Haskell code
      extraImports = ["qualified Data.Map as Map"];
      extraFunctions = ''
        -- Custom function
        myPattern = fast 2 $ sound "bd sd"
      '';
    };
  };
}
```

### SuperCollider Configuration

Fine-tune SuperCollider server settings:

```nix
{
  programs.tidalcycles = {
    enable = true;

    supercollider = {
      enable = true;

      # Use a specific package
      package = pkgs.supercollider;

      serverOptions = {
        numBuffers = 1024 * 256;
        memSize = 8192 * 32;
        numWireBufs = 128;
        maxNodes = 1024 * 32;
        numOutputBusChannels = 2;
        numInputBusChannels = 2;
        sampleRate = 48000;
        blockSize = 64;
      };
    };
  };
}
```

### SuperDirt Configuration

Configure SuperDirt startup and sample loading:

```nix
{
  programs.tidalcycles = {
    enable = true;

    superdirt = {
      enable = true;

      # Choose profile: minimal, standard, advanced
      profile = "standard";

      # Additional quarks to install
      quarks = ["SuperDirt" "Vowel" "VSTPlugin"];

      # Add sample packs
      samplePacks = [
        {
          name = "808-samples";
          url = "https://example.com/808.tar.gz";
          sha256 = "...";
        }
      ];

      # Extra sample directories
      extraSampleDirs = [
        "/path/to/my/samples"
      ];

      # Additional SuperDirt configuration
      extraConfig = ''
        // Custom effects chain
        ~dirt.orbits[0].setGlobalEffects([\\distortion, \\reverb]);
      '';
    };
  };
}
```

### MIDI Configuration

Connect TidalCycles to MIDI devices:

```nix
{
  programs.tidalcycles = {
    enable = true;

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
  };
}
```

### OSC Configuration

Send patterns to external applications:

```nix
{
  programs.tidalcycles = {
    enable = true;

    osc = {
      enable = true;

      targets = [
        {
          name = "processing";
          address = "127.0.0.1";
          port = 12000;
        }
        {
          name = "touchdesigner";
          address = "192.168.1.100";
          port = 7000;
        }
      ];
    };
  };
}
```

### Editor Integration

#### Vim/Neovim

```nix
{
  programs.tidalcycles = {
    enable = true;

    editor.vim = {
      enable = true;
      # Uses vim-tidal by default
    };
  };
}
```

#### Emacs

```nix
{
  programs.tidalcycles = {
    enable = true;

    editor.emacs = {
      enable = true;
      # Uses tidal-mode by default
    };
  };
}
```

#### VS Code

```nix
{
  programs.tidalcycles = {
    enable = true;

    editor.vscode.enable = true;
  };
}
```

### Development Options

For Haskell development alongside TidalCycles:

```nix
{
  programs.tidalcycles = {
    enable = true;

    development = {
      enableGhc = true;  # Default
      enableCabal = true;
      enableStack = true;

      extraHaskellPackages = with pkgs.haskellPackages; [
        lens
        vector
        aeson
      ];
    };
  };
}
```

## Helper Scripts

The module provides several helper scripts:

- **`install-superdirt`**: Install SuperDirt and required quarks
- **`install-sc3-plugins`** (macOS only): Install SC3 plugins
- **`install-sample-packs`**: Install configured sample packs
- **`start-superdirt`**: Start SuperDirt with your configuration
- **`tidal-repl`**: Start TidalCycles REPL with boot script loaded
- **`sclang`**: Wrapped SuperCollider interpreter with environment setup

## Boot Script Profiles

### Minimal
Basic TidalCycles setup with core functionality only.

### Standard (Recommended)
Includes all standard stream controls and transitions:
- Pattern streams (d1-d12)
- Transitions (xfade, jump, interpolate, etc.)
- Stream controls (hush, solo, mute, etc.)

### Extended
Standard profile plus additional helper functions and utilities.

### MIDI
Optimized for MIDI-focused live coding with MIDI device integration.

## SuperDirt Profiles

### Minimal
Basic SuperDirt setup with default samples only.

### Standard (Recommended)
Includes:
- Proper buffer sizing for stability
- Extra sample directory loading
- 12 orbits by default

### Advanced
Performance-tuned configuration with:
- Larger buffers for complex patterns
- Custom audio routing
- Optimized for low-latency performance

## Platform Differences

### macOS
- Uses CoreAudio driver
- SC3 plugins require separate installation via `install-sc3-plugins`
- Extensions directory: `~/Library/Application Support/SuperCollider/Extensions`

### Linux
- Uses JACK or ALSA
- SC3 plugins can be installed via Nix directly
- Extensions directory: `~/.local/share/SuperCollider/Extensions`

## File Locations

- Boot script: `~/.config/tidal/BootTidal.hs`
- SuperDirt startup: `~/.config/SuperCollider/start-superdirt.scd`
- MIDI config: `~/.config/tidal/midi.hs`
- OSC config: `~/.config/tidal/osc.hs`
- Sample directory: `~/.local/share/SuperCollider/samples-extra/`

## Troubleshooting

### SuperDirt won't start

1. Check if SuperDirt quarks are installed:
   ```bash
   install-superdirt
   ```

2. Check SuperCollider server options (increase memory if needed):
   ```nix
   supercollider.serverOptions.memSize = 8192 * 64;
   ```

### Audio dropouts or glitches

1. Increase latency:
   ```nix
   boot.connection.latency = 0.2;
   ```

2. Increase buffer size:
   ```nix
   supercollider.serverOptions.blockSize = 128;
   ```

### MIDI not working

1. Ensure MIDI is enabled:
   ```nix
   midi.enable = true;
   ```

2. Check device names match exactly
3. Try increasing MIDI latency

## Example Configurations

### Minimal Setup

```nix
{
  programs.tidalcycles.enable = true;
}
```

### Performance Setup

```nix
{
  programs.tidalcycles = {
    enable = true;

    boot.profile = "standard";

    supercollider.serverOptions = {
      memSize = 8192 * 64;
      maxNodes = 1024 * 64;
    };

    superdirt = {
      profile = "advanced";
      quarks = ["SuperDirt" "Vowel" "VSTPlugin"];
    };
  };
}
```

### Studio Setup with MIDI and OSC

```nix
{
  programs.tidalcycles = {
    enable = true;

    boot = {
      profile = "midi";
      orbits = 16;
    };

    midi = {
      enable = true;
      devices = [
        { name = "Digitakt"; channels = 8; latency = 0.05; }
        { name = "MIDI Fighter"; channels = 16; latency = 0.1; }
      ];
    };

    osc = {
      enable = true;
      targets = [
        { name = "resolume"; address = "127.0.0.1"; port = 7000; }
      ];
    };

    editor.vim.enable = true;
  };
}
```

## Contributing

This module is part of the [tidalcycles-nix](https://github.com/yourusername/tidalcycles-nix) project.

## License

MIT
