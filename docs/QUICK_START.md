# TidalCycles-Nix Quick Start

## Installation

### As a Flake Input

Add to your `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
    tidalcycles-nix.url = "github:yourusername/tidalcycles-nix";
  };

  outputs = {nixpkgs, home-manager, tidalcycles-nix, ...}: {
    homeConfigurations.youruser = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-darwin; # or x86_64-linux
      modules = [
        tidalcycles-nix.homeManagerModules.tidalcycles
        {
          programs.tidalcycles.enable = true;
        }
      ];
    };
  };
}
```

### Minimal Configuration

```nix
{
  programs.tidalcycles.enable = true;
}
```

That's it! Rebuild your home-manager configuration.

## First Run

After rebuilding, run these commands in order:

```bash
# 1. Install SuperDirt quarks (one-time setup)
install-superdirt

# 2. (macOS only) Install SC3 plugins (optional)
install-sc3-plugins

# 3. Start SuperDirt (in one terminal)
start-superdirt

# 4. Start Tidal REPL (in another terminal)
tidal-repl
```

## Quick Patterns

Once in the Tidal REPL, try these:

```haskell
-- Basic drum pattern
d1 $ sound "bd sd bd sd"

-- With effects
d1 $ sound "bd sd" # speed 2 # room 0.3

-- Stop all patterns
hush

-- Set tempo (120 BPM = 2 cycles per second)
setcps 2
```

## Pre-configured Profiles

Import a complete profile instead of configuring from scratch:

```nix
{
  imports = [
    tidalcycles-nix.homeManagerModules.tidalcycles
    tidalcycles-nix.profiles.standard  # or minimal, performance, studio
  ];
}
```

### Available Profiles

- **minimal** - Basic setup (8 orbits, lower resource usage)
- **standard** - Recommended (12 orbits, balanced)
- **performance** - High-end (16 orbits, low latency)
- **studio** - Full-featured (MIDI, OSC, editor integration)

## Common Configurations

### More Orbits

```nix
{
  programs.tidalcycles = {
    enable = true;
    boot.orbits = 16;  # Default is 12
  };
}
```

### Lower Latency

```nix
{
  programs.tidalcycles = {
    enable = true;
    boot.connection.latency = 0.05;  # Default is 0.1
  };
}
```

### More Power

```nix
{
  programs.tidalcycles = {
    enable = true;
    supercollider.serverOptions = {
      memSize = 8192 * 64;  # 4x default
      maxNodes = 1024 * 64;  # 2x default
    };
  };
}
```

### Add MIDI Device

```nix
{
  programs.tidalcycles = {
    enable = true;
    midi = {
      enable = true;
      devices = [
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

### Add OSC Target

```nix
{
  programs.tidalcycles = {
    enable = true;
    osc = {
      enable = true;
      targets = [
        {
          name = "resolume";
          address = "127.0.0.1";
          port = 7000;
        }
      ];
    };
  };
}
```

### Vim Integration

```nix
{
  programs.tidalcycles = {
    enable = true;
    editor.vim.enable = true;
  };
}
```

## Helper Commands

- `install-superdirt` - Install SuperDirt quarks
- `install-sc3-plugins` - Install SC3 plugins (macOS)
- `install-sample-packs` - Install configured sample packs
- `start-superdirt` - Start SuperDirt server
- `tidal-repl` - Start TidalCycles REPL
- `sclang` - Run SuperCollider interpreter

## Configuration Files

After installation, these files are created:

- `~/.config/tidal/BootTidal.hs` - TidalCycles boot script
- `~/.config/SuperCollider/start-superdirt.scd` - SuperDirt startup
- `~/.local/share/SuperCollider/samples-extra/` - Extra sample directory

## Troubleshooting

### SuperDirt won't start

```bash
# Reinstall quarks
install-superdirt
```

### Audio glitches

Increase latency:
```nix
boot.connection.latency = 0.2;  # Higher = more stable, less responsive
```

Or increase buffer size:
```nix
supercollider.serverOptions.blockSize = 128;  # Default is 64
```

### Pattern execution delayed

Lower latency:
```nix
boot.connection.latency = 0.05;  # Lower = more responsive, less stable
```

### MIDI not working

Check device name exactly matches:
```bash
# On macOS
/Applications/SuperCollider.app/Contents/MacOS/sclang -e "MIDIClient.init; MIDIClient.sources;"

# On Linux
aconnect -l
```

## Learn More

- Full documentation: `modules/home-manager/README.md`
- Examples: `examples/` directory
- TidalCycles docs: https://tidalcycles.org/
- SuperCollider docs: https://supercollider.github.io/

## Getting Help

- Check `modules/home-manager/README.md` for detailed options
- See examples in `examples/` directory
- Join TidalCycles community: https://club.tidalcycles.org/
