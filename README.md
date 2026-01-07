<h1 align='center'>tidalcycles-nix</h1>
<div align='center'>
    <p>A comprehensive, standalone Nix flake providing a home-manager module for the <a href="https://tidalcycles.org/">TidalCycles</a> live coding environment.</p>
    <div align='center'>
  <a href='https://github.com/DivitMittal/tidalcycles-nix'>
  <img src='https://img.shields.io/github/repo-size/DivitMittal/tidalcycles-nix?&style=for-the-badge&logo=github'>
  </a>
  <a href='https://github.com/DivitMittal/tidalcycles-nix/blob/master/LICENSE'>
  <img src='https://img.shields.io/static/v1.svg?style=for-the-badge&label=License&message=MIT&logo=unlicense'/>
  </a>
    </div>
    <br>
</div>

---

<div align='center'>
    <a href="https://github.com/DivitMittal/tidalcycles-nix/actions/workflows/flake-check.yml">
  <img src="https://github.com/DivitMittal/tidalcycles-nix/actions/workflows/flake-check.yml/badge.svg" alt="nix-flake-check"/>
    </a>
    <a href="https://github.com/DivitMittal/tidalcycles-nix/actions/workflows/flake-lock-update.yml">
  <img src="https://github.com/DivitMittal/tidalcycles-nix/actions/workflows/flake-lock-update.yml/badge.svg" alt="flake-lock-update"/>
    </a>
</div>

---

This Nix flake manages TidalCycles (Haskell), SuperCollider, and SuperDirt with extensive configuration options, separate Haskell boot script profiles, helper scripts, and cross-platform support (NixOS, nix-darwin, standalone home-manager).

## Features

### Complete TidalCycles Setup

The module provides a fully integrated TidalCycles environment, including:
- **TidalCycles** Haskell library for pattern-based live coding
- **SuperCollider** audio synthesis engine
- **SuperDirt** sample-based synthesizer for TidalCycles

### Highly Configurable

Extensive configuration options allow you to customize every aspect of your setup:
- **Boot script profiles** with separate Haskell files (minimal, standard, extended, midi)
- **SuperCollider server optimization** (buffer sizes, memory allocation, sample rates)
- **Connection parameters** (latency, port, address configuration)
- **Custom boot scripts** for advanced users

### Multiple Profiles

Pre-configured profiles for different use cases:
- **Minimal** - Lightweight setup for beginners or low-resource systems
- **Standard** - Balanced configuration for most users (recommended)
- **Performance** - Optimized for complex patterns and live performance
- **Studio** - Full-featured setup with MIDI, OSC, and advanced options

### MIDI & OSC Support

Control hardware synthesizers and external applications:
- Multi-device MIDI configuration with per-device latency settings
- OSC (Open Sound Control) target configuration
- Declarative device management through Nix

### Editor Integration

Support for popular text editors:
- **Vim/Neovim** integration
- **Emacs** configuration
- **VS Code** extension support
- **Atom** (legacy) support

### Cross-Platform

Works seamlessly across different platforms:
- **NixOS** - Native integration with system audio
- **nix-darwin** - macOS support with platform-specific optimizations
- **Standalone home-manager** - Use on any Linux distribution with Nix

### Helper Scripts

Convenient scripts for common tasks:
- `install-superdirt` - Install SuperDirt quarks in SuperCollider
- `install-sc3-plugins` - Install SC3-Plugins (macOS only)
- `start-superdirt` - Start the SuperDirt audio engine
- `tidal-repl` - Launch TidalCycles REPL with configured boot script
- `sclang` - SuperCollider interpreter wrapper

## Flakes Usage

To use this module in your own configuration, add it to your `flake.nix` inputs:

```nix
## flake.nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    tidalcycles-nix.url = "github:DivitMittal/tidalcycles-nix";
  };

  outputs = { self, nixpkgs, home-manager, tidalcycles-nix, ... }: {
    homeConfigurations.your-user = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux; # Or your system
      modules = [
        ## Import the module
        tidalcycles-nix.homeManagerModules.default

        ## Your other modules
        ./home.nix
      ];
    };
  };
}
```

Then, enable it in your `home.nix`:

```nix
## home.nix
{
  programs.tidalcycles = {
    enable = true;
    boot.profile = "standard";
    supercollider.enable = true;
    superdirt.enable = true;
  };
}
```

**Rebuild and Install:**

```bash
# For home-manager
home-manager switch --flake .

# Install SuperDirt quarks
install-superdirt

# Install SC3-Plugins (macOS only, required for SuperDirt)
install-sc3-plugins

# Start SuperDirt
start-superdirt

# In another terminal, start TidalCycles
tidal-repl
```

---

## Configuration Profiles

### Minimal
Perfect for beginners or low-resource systems:
```nix
programs.tidalcycles = tidalcycles-nix.profiles.minimal;
```

### Standard (Recommended)
Balanced configuration for most users:
```nix
programs.tidalcycles = tidalcycles-nix.profiles.standard;
```

### Performance
Optimized for complex patterns and live performance:
```nix
programs.tidalcycles = tidalcycles-nix.profiles.performance;
```

### Studio
Full-featured setup with MIDI, OSC, and advanced options:
```nix
programs.tidalcycles = tidalcycles-nix.profiles.studio;
```

---

## Advanced Configuration

### Custom Boot Script

```nix
programs.tidalcycles = {
  enable = true;

  boot = {
    profile = "extended";
    orbits = 16;
    connection = {
      address = "127.0.0.1";
      port = 57120;
      latency = 0.05;
    };
    extraFunctions = ''
      let myCustomFunction = ...
    '';
  };
};
```

### MIDI Configuration

```nix
programs.tidalcycles = {
  enable = true;

  midi = {
    enable = true;
    devices = [
      {
        name = "Elektron Digitakt";
        channels = 16;
        latency = 0.1;
      }
      {
        name = "Novation Circuit";
        channels = 16;
        latency = 0.05;
      }
    ];
  };
};
```

### Custom Sample Packs

```nix
programs.tidalcycles = {
  enable = true;

  superdirt.samples = {
    extraDirs = [
      "${config.home.homeDirectory}/Music/samples"
      "/path/to/custom/samples"
    ];
    packs = [
      {
        name = "custom-drums";
        url = "https://example.com/samples.zip";
        sha256 = "sha256-...";
      }
    ];
  };
};
```

### SuperCollider Optimization

```nix
programs.tidalcycles = {
  enable = true;

  supercollider.server = {
    numBuffers = 1024 * 512;
    memSize = 8192 * 64;
    maxNodes = 1024 * 64;
    sampleRate = 48000;
    blockSize = 64;
  };
};
```

---

## Module Options

See [modules/home-manager/README.md](modules/home-manager/README.md) for complete option documentation.

---

## Helper Scripts

The module provides several helper scripts:

- **`install-superdirt`** - Install SuperDirt quarks in SuperCollider
- **`install-sc3-plugins`** - Install SC3-Plugins (macOS only)
- **`start-superdirt`** - Start the SuperDirt audio engine
- **`tidal-repl`** - Launch TidalCycles REPL with configured boot script
- **`sclang`** - SuperCollider interpreter wrapper

## Boot Script Profiles

The module includes several boot script profiles:

- **minimal.hs** - Bare essentials (d1-d4, basic controls)
- **standard.hs** - Recommended (d1-d12, transitions, all controls)
- **extended.hs** - Additional utilities and custom functions
- **midi.hs** - MIDI-focused configuration

You can also provide your own custom boot script:

```nix
programs.tidalcycles.boot.customScript = ./my-boot.hs;
```

---

## Platform-Specific Notes

### macOS (nix-darwin)

- SC3-Plugins must be installed manually using `install-sc3-plugins`
- SuperCollider is typically installed via Homebrew casks
- Use CoreAudio for audio routing

### NixOS

- SC3-Plugins are available in nixpkgs
- JACK or ALSA for audio
- Optional systemd services for auto-starting SuperDirt

### Standalone home-manager

- Works on any Linux distribution with Nix installed
- Requires manual audio setup

---

## Troubleshooting

### SuperCollider can't find SC3-Plugins (macOS)

```bash
# Install SC3-Plugins
install-sc3-plugins

# Restart SuperCollider or rerun
start-superdirt
```

### TidalCycles can't connect to SuperDirt

1. Ensure SuperDirt is running: `start-superdirt`
2. Check port configuration matches (default: 57120)
3. Verify latency settings

### Audio device not found

Check your SuperCollider device configuration:
```nix
programs.tidalcycles.supercollider.server.device = "Your Audio Interface";
```

---

## Examples

See the [examples/](examples/) directory for complete configuration examples:

- [basic.nix](examples/basic.nix) - Minimal working setup
- [advanced.nix](examples/advanced.nix) - Full-featured configuration
- [midi-focused.nix](examples/midi-focused.nix) - Hardware synth control

---

## License

MIT License - see [LICENSE](LICENSE) for details

---

## Resources

- [TidalCycles Documentation](https://tidalcycles.org/docs/)
- [SuperCollider Documentation](https://doc.sccode.org/)
- [SuperDirt Documentation](https://github.com/musikinformatik/SuperDirt)
- [Nix Home Manager](https://github.com/nix-community/home-manager)

---

## Credits

This module was created to make TidalCycles more accessible to the Nix community. It builds upon the excellent work of the TidalCycles, SuperCollider, and SuperDirt communities.
