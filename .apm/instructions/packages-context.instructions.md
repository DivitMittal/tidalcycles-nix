---
description: Boot-script and SuperCollider-script package builders in packages/
applyTo: "packages/**"
---

## Package Layout

```
packages/
  boot-scripts/
    default.nix          # mkBootScript builder function
    profiles/            # Haskell source files consumed by mkBootScript
      minimal.hs         # d1-d4, basic controls
      standard.hs        # d1-d12, all transitions (default profile)
      extended.hs        # Advanced utilities, custom functions
      midi.hs            # MIDI-focused setup
  supercollider-scripts/
    default.nix          # mkStartScript, mkInstallScript builder functions
    templates/           # SuperCollider source files consumed by the builders
      minimal.scd        # 4 orbits, reduced buffers
      standard.scd       # 12 orbits, extra samples support
      advanced.scd       # 16 orbits, MIDI, high-performance
```

## Boot Scripts (`boot-scripts/`)

`profiles/*.hs` files are plain Haskell source for `BootTidal.hs`. They are **not** Nix expressions.

`default.nix` exports `mkBootScript { name, src }` which reads the `.hs` file and returns a derivation containing the rendered boot script.

**To add a new boot script profile:**
1. Create `packages/boot-scripts/profiles/<name>.hs` with valid Haskell/TidalCycles syntax.
2. Add `"<name>"` to the `boot.profile` enum in `modules/home-manager/tidalcycles.nix`.
3. Verify with `nix flake check`.

## SuperCollider Scripts (`supercollider-scripts/`)

`templates/*.scd` files are plain SuperCollider source. They are **not** Nix expressions.

`default.nix` exports:
- `mkStartScript { name, src }` — builds a SuperDirt startup `.scd` derivation.
- `mkInstallScript { name, src }` — builds a quark installation `.scd` derivation.

**To add a new SuperCollider template:**
1. Create `packages/supercollider-scripts/templates/<name>.scd` using standard SuperCollider `.scd` syntax.
2. Add `"<name>"` to the `superdirt.profile` enum in `modules/home-manager/tidalcycles.nix`.
3. Verify with `nix flake check`.

## Critical Rule

**Never inline script content inside the module.** All `.hs` and `.scd` content lives in separate files under `profiles/` or `templates/`. The builder functions read the file at build time. This keeps the Nix module readable and makes scripts independently editable and testable.
