# TidalCycles Nix

A comprehensive NixOS/home-manager module for [TidalCycles](https://tidalcycles.org/) live coding environment.

## Features

- 🎵 **Complete TidalCycles setup** - Haskell library, SuperCollider, and SuperDirt
- 🔧 **Highly configurable** - Extensive options for customization
- 🚀 **Multiple profiles** - Minimal, standard, performance, and studio configurations
- 🎹 **MIDI & OSC support** - Control hardware synths and external applications
- 💻 **Editor integration** - Vim, Emacs, VS Code support
- 🍎 **Cross-platform** - Works on NixOS, nix-darwin (macOS), and standalone home-manager
- 📦 **Helper scripts** - Easy installation and management tools
- 🎨 **Separate Haskell files** - Clean, modular boot script organization

## Quick Start

### 1. Add to your flake inputs

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
    tidalcycles-nix.url = "github:yourusername/tidalcycles-nix";
  };
}
```

### 2. Import the module

```nix
{
  outputs = {nixpkgs, home-manager, tidalcycles-nix, ...}: {
    homeConfigurations.yourusername = home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs {system = "x86_64-linux";};
      modules = [
        tidalcycles-nix.homeManagerModules.default
        {
          programs.tidalcycles = {
            enable = true;
            boot.profile = "standard";
            supercollider.enable = true;
            superdirt.enable = true;
          };
        }
      ];
    };
  };
}
```

### 3. Rebuild and install

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

## Module Options

See [modules/home-manager/README.md](modules/home-manager/README.md) for complete option documentation.

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

## Examples

See the [examples/](examples/) directory for complete configuration examples:

- [basic.nix](examples/basic.nix) - Minimal working setup
- [advanced.nix](examples/advanced.nix) - Full-featured configuration
- [midi-focused.nix](examples/midi-focused.nix) - Hardware synth control

## Development

```bash
# Enter development environment
nix develop

# Format code
nix fmt

# Run checks
nix flake check

# Update dependencies
nix flake update
```

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Run `nix fmt` before committing
4. Submit a pull request

## License

MIT License - see [LICENSE](LICENSE) for details

## Resources

- [TidalCycles Documentation](https://tidalcycles.org/docs/)
- [SuperCollider Documentation](https://doc.sccode.org/)
- [SuperDirt Documentation](https://github.com/musikinformatik/SuperDirt)
- [Nix Home Manager](https://github.com/nix-community/home-manager)

## Credits

This module was created to make TidalCycles more accessible to the Nix community. It builds upon the excellent work of the TidalCycles, SuperCollider, and SuperDirt communities.
