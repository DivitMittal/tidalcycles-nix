## Project Overview

tidalcycles-nix is a comprehensive, standalone Nix flake providing a home-manager module for TidalCycles live coding. It manages TidalCycles (Haskell), SuperCollider, and SuperDirt with extensive configuration options, separate Haskell boot script profiles, helper scripts, and cross-platform support (NixOS, nix-darwin, standalone home-manager).

## Development Commands

### Nix Flake Commands
```bash
nix develop              # Enter development environment
nix flake check          # Run all checks (formatting, linting, builds)
nix flake show           # Display flake outputs
nix flake update         # Update all inputs
```

### Formatting and Linting
```bash
nix fmt                  # Format all Nix files (alejandra, deadnix, statix)
alejandra .              # Nix formatting only
deadnix -e               # Find and report dead Nix code
statix check             # Lint Nix code for anti-patterns
```

### Pre-commit Hooks
Pre-commit hooks are automatically installed when entering `nix develop`:
- alejandra (Nix formatting)
- deadnix (dead code detection)
- statix (Nix linting)

### Testing Module Integration
```bash
# Test module can be evaluated (from a flake using this module)
nix eval .#homeConfigurations.<user>.config.programs.tidalcycles.enable

# Build without switching (dry-run)
home-manager build --flake .#<user>

# Actual rebuild and switch
home-manager switch --flake .#<user>
```

### Helper Scripts (After Installation)
```bash
install-superdirt        # Install SuperDirt quarks in SuperCollider
install-sc3-plugins      # Install SC3-Plugins (macOS only)
start-superdirt          # Start SuperDirt audio engine
tidal-repl               # Launch TidalCycles REPL with boot script
sclang                   # SuperCollider interpreter wrapper
```

## Architecture

### Core Structure
```
tidalcycles-nix/
├── flake.nix                       # Main flake, uses flake-parts
├── flake/                          # Flake-parts modules
│   ├── devshells.nix              # nix develop environment
│   ├── formatters.nix             # treefmt config (alejandra, deadnix, statix)
│   ├── checks.nix                 # Pre-commit hooks and validation
│   └── packages.nix               # Exported packages
├── lib/                            # Custom utilities and types
│   ├── default.nix                # Exports custom and types
│   ├── custom.nix                 # scanPaths, mkBootScript helpers
│   └── types.nix                  # Custom Nix types (connectionType, midiDeviceType, etc.)
├── modules/
│   ├── home-manager/
│   │   ├── default.nix            # Auto-imports tidalcycles.nix
│   │   └── tidalcycles.nix        # Main module (~622 lines, comprehensive options)
│   └── nixos/
│       ├── default.nix
│       └── audio.nix              # System-level audio configuration (future)
├── packages/
│   ├── boot-scripts/              # Haskell BootTidal.hs generators
│   │   ├── default.nix            # mkBootScript function
│   │   └── profiles/              # Separate .hs files (NOT inline strings)
│   │       ├── minimal.hs         # d1-d4, basic controls
│   │       ├── standard.hs        # d1-d12, all transitions (current default)
│   │       ├── extended.hs        # Advanced utilities, custom functions
│   │       └── midi.hs            # MIDI-focused setup
│   └── supercollider-scripts/     # SuperCollider .scd generators
│       ├── default.nix            # mkStartScript, mkInstallScript functions
│       └── templates/
│           ├── minimal.scd        # 4 orbits, reduced buffers
│           ├── standard.scd       # 12 orbits, extra samples support
│           └── advanced.scd       # 16 orbits, MIDI, high-performance
├── profiles/                       # Pre-configured option sets
│   ├── minimal.nix                # Lightweight (beginners, low-resource)
│   ├── standard.nix               # Recommended defaults
│   ├── performance.nix            # Optimized buffers/memory
│   └── studio.nix                 # Full-featured (MIDI, OSC, all helpers)
└── examples/                       # Usage examples
    ├── basic.nix
    ├── advanced.nix
    └── midi-focused.nix
```

### Key Dependencies
- **flake-parts**: Modular flake organization
- **nixpkgs-unstable**: Latest packages (TidalCycles, SuperCollider)
- **devshell**: Development environment setup
- **treefmt-nix**: Code formatting configuration
- **git-hooks**: Pre-commit hook management

### Module Architecture

**Main Module** (`modules/home-manager/tidalcycles.nix`):
- Exposes `programs.tidalcycles.*` options via home-manager
- Platform-aware: detects macOS vs Linux via `pkgs.stdenv.isDarwin`
- Imports custom types from `lib/types.nix`
- Calls script builders from `packages/boot-scripts/` and `packages/supercollider-scripts/`
- Generates helper scripts dynamically based on configuration

**Options Structure** (simplified):
```nix
programs.tidalcycles = {
  enable = bool;
  package = package;  # TidalCycles Haskell library

  boot = {
    profile = enum ["minimal" "standard" "extended" "midi" "custom"];
    customScript = nullOr path;  # Override profile with custom BootTidal.hs
    connection = { address, port, latency };
    frameTimespan = float;
    verbose = bool;
    orbits = int;
    extraImports = listOf string;
    extraFunctions = string;
  };

  supercollider = {
    enable = bool;
    package = package;
    serverOptions = {
      numBuffers, memSize, numWireBufs, maxNodes,
      numOutputBusChannels, numInputBusChannels,
      sampleRate, blockSize, device
    };
    sc3plugins = { enable, version, extraPlugins };
  };

  superdirt = {
    enable = bool;
    profile = enum ["minimal" "standard" "advanced" "custom"];
    customScript = nullOr path;
    quarks = listOf string;  # Default: ["SuperDirt", "Vowel"]
    samples = {
      defaultDir, extraDirs,
      packs = listOf { name, url, sha256 }
    };
  };

  midi = {
    enable = bool;
    devices = listOf { name, channels, latency };
  };

  osc = {
    enable = bool;
    targets = listOf { name, address, port };
  };

  helpers = {
    installScripts = bool;
    scripts = { installSuperdirt, installSc3plugins, startSuperdirt, tidalRepl, sclang };
  };

  editor = {
    vim, emacs, vscode, atom
  };

  development = {
    extraPackages, haskellPackages, ghcWithPackages
  };
};
```

### Script Generation Flow

1. **Boot Script**: `bootScripts.mkBootScript` reads profile from `packages/boot-scripts/profiles/*.hs`
2. **SuperDirt Script**: `scScripts.mkStartScript` reads template from `packages/supercollider-scripts/templates/*.scd`
3. **Helper Scripts**: Generated in `modules/home-manager/tidalcycles.nix` using `pkgs.writeShellScriptBin`
4. **Installation**: Scripts placed in `home.packages` when `helpers.installScripts = true`

## Development Guidelines

### File Organization

**Adding a new boot script profile**:
1. Create `packages/boot-scripts/profiles/<name>.hs`
2. Add profile name to `boot.profile` enum in `modules/home-manager/tidalcycles.nix`
3. Test with: `programs.tidalcycles.boot.profile = "<name>";`

**Adding a new SuperCollider template**:
1. Create `packages/supercollider-scripts/templates/<name>.scd`
2. Add profile name to `superdirt.profile` enum
3. Templates should use standard SuperCollider .scd syntax

**Adding new module options**:
1. Define option in `modules/home-manager/tidalcycles.nix` options section
2. Add corresponding custom type in `lib/types.nix` if complex
3. Implement in config section using `mkIf` and `mkMerge`
4. Update `modules/home-manager/README.md` with option documentation

### Platform Considerations

**macOS (nix-darwin)**:
- SC3-Plugins installation is handled via download (not nixpkgs)
- SuperCollider path: `/Applications/SuperCollider.app/Contents/MacOS/sclang`
- Use `pkgs.stdenv.isDarwin` for macOS-specific logic
- Extensions directory: `~/Library/Application Support/SuperCollider/Extensions`

**Linux (NixOS)**:
- SC3-Plugins available in nixpkgs
- SuperCollider path: `${pkgs.supercollider}/bin/sclang`
- Extensions directory: `~/.local/share/SuperCollider/Extensions`
- Can use systemd services for auto-starting SuperDirt

**Cross-platform patterns**:
```nix
scPath =
  if pkgs.stdenv.isDarwin
  then "${cfg.supercollider.package}/Applications/SuperCollider.app/Contents/MacOS/sclang"
  else "${cfg.supercollider.package}/bin/sclang";
```

### Code Quality

**Nix Code Standards**:
- Use explicit `lib.` prefix (NO `with lib;`)
- Prefer `lib.mkMerge` for complex conditional configs
- Use `lib.optionalAttrs` over `if-then-else {}`
- Use `lib.filterAttrs` to remove null/empty values
- Follow .editorconfig: 2-space indent, LF endings, UTF-8

**Formatting is enforced**:
- alejandra: Nix formatting
- deadnix: Removes unused let bindings, function args
- statix: Lints anti-patterns

**Pre-commit checks catch**:
- Unformatted code
- Large files (> 500KB)
- Trailing whitespace
- Missing shebangs on executables
- Private keys in commits

### Haskell Boot Script Conventions

**Profile naming**:
- `minimal.hs`: Bare essentials (d1-d4, p, hush)
- `standard.hs`: Full featured (d1-d12, all transitions, utilities)
- `extended.hs`: Custom functions, advanced patterns
- `midi.hs`: MIDI device setup, CC mappings

**Script structure**:
```haskell
:set -XOverloadedStrings
:set prompt ""

import Sound.Tidal.Context

tidal <- startTidal (superdirtTarget {...}) (defaultConfig {...})

-- Define stream controls
let p = streamReplace tidal
    hush = streamHush tidal
    d1 = p 1
    ...

:set prompt "tidal> "
```

**Parameter replacement**:
Boot scripts use string replacement for dynamic config:
- `oLatency = 0.1` → `oLatency = ${toString conn.latency}`
- `oPort = 57120` → `oPort = ${toString conn.port}`
- `0 ! 12` → `0 ! ${toString orbits}`

### SuperCollider Script Conventions

**Template naming matches boot profiles**:
- `minimal.scd`: 4 orbits, reduced buffers
- `standard.scd`: 12 orbits, extra samples
- `advanced.scd`: 16 orbits, MIDI, high-performance

**Script structure**:
```supercollider
(
  s.reboot {
    s.options.numBuffers = 1024 * 256;
    s.options.memSize = 8192 * 32;
    // ... more server options

    s.waitForBoot {
      ~dirt = SuperDirt(2, s);
      ~dirt.loadSoundFiles;
      ~dirt.start(57120, 0 ! 12);
    };
  };
)
```

### Profile System

Profiles are pre-configured option sets in `profiles/*.nix`:

**Usage in consumer flakes**:
```nix
programs.tidalcycles = inputs.tidalcycles-nix.profiles.standard;
```

**Profile structure**:
```nix
{
  enable = true;
  boot.profile = "standard";
  supercollider.enable = true;
  superdirt.enable = true;
  helpers.installScripts = true;
  # ... more defaults
}
```

Profiles can be overridden:
```nix
programs.tidalcycles = lib.mkMerge [
  inputs.tidalcycles-nix.profiles.performance
  { boot.orbits = 24; }  # Override orbit count
];
```

### Flake Outputs

**homeManagerModules**:
- `default`: Points to `modules/home-manager/`
- `tidalcycles`: Main module directly
- `supercollider`: Standalone SuperCollider config (future)
- `superdirt`: Standalone SuperDirt config (future)

**nixosModules** (future):
- `audio`: System-level audio configuration
- Real-time privileges, audio group membership

**profiles**:
- `minimal`, `standard`, `performance`, `studio`
- Importable as full option sets

**overlays.default**:
- Adds `tidalcycles-scripts` to pkgs
- Contains helper script derivations

**lib.tidalcycles**:
- Custom utility functions
- `scanPaths`, `mkBootScript`, custom types

### Integration with OS-nixCfg

This module is designed to be used as an external flake input:

```nix
# In OS-nixCfg flake.nix
inputs.tidalcycles-nix = {
  url = "github:DivitMittal/tidalcycles-nix";
  inputs.nixpkgs.follows = "nixpkgs";
};

# In home-manager config
{inputs, ...}: {
  imports = [inputs.tidalcycles-nix.homeManagerModules.default];

  programs.tidalcycles = {
    enable = true;
    boot.profile = "standard";
    supercollider = {
      enable = true;
      package = pkgs.brewCasks.supercollider;  # macOS
    };
    superdirt.enable = true;
  };
}
```

The flake uses path-based input during development:
```nix
url = "path:/Users/div/Projects/tidalcycles-nix";
```

Switch to GitHub URL when publishing:
```nix
url = "github:DivitMittal/tidalcycles-nix";
```
