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
```

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

### Module Architecture

**Main Module** (`modules/home-manager/tidalcycles.nix`):
- Exposes `programs.tidalcycles.*` options via home-manager
- Platform-aware: detects macOS vs Linux via `pkgs.stdenv.isDarwin`
- Imports custom types from `lib/types.nix`
- Calls script builders from `packages/boot-scripts/` and `packages/supercollider-scripts/`
- Generates helper scripts dynamically based on configuration

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

### Platform Considerations

**macOS (nix-darwin)**:
- SC3-Plugins installation is handled via download (not nixpkgs)
- SuperCollider path: `/Applications/SuperCollider.app/Contents/MacOS/sclang`
- Use `pkgs.stdenv.isDarwin` for macOS-specific logic

**Linux (NixOS)**:
- SC3-Plugins available in nixpkgs
- SuperCollider path: `${pkgs.supercollider}/bin/sclang`
- Can use systemd services for auto-starting SuperDirt

### Code Quality

**Nix Code Standards**:
- Use explicit `lib.` prefix (NO `with lib;`)
- Prefer `lib.mkMerge` for complex conditional configs
- Use `lib.optionalAttrs` over `if-then-else {}`
- Use `lib.filterAttrs` to remove null/empty values
- Follow .editorconfig: 2-space indent, LF endings, UTF-8

### Integration with OS-nixCfg

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
    supercollider.enable = true;
    superdirt.enable = true;
  };
}
```
