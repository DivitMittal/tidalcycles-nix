---
description: Home-manager and NixOS module context for the modules/ directory
applyTo: "modules/**"
---

## Module Layout

```
modules/
  home-manager/
    default.nix        # Auto-imports tidalcycles.nix via import-tree
    tidalcycles.nix    # Main module (~622 lines)
  nixos/
    default.nix
    audio.nix          # System-level audio config (optional, not imported by default)
```

## `modules/home-manager/tidalcycles.nix`

The primary deliverable of this repo. Key characteristics:

- Exposes the `programs.tidalcycles.*` option namespace to home-manager configurations.
- **Platform-aware**: branches on `pkgs.stdenv.isDarwin` for macOS-specific paths and behaviour (SC3-Plugins download, sclang path).
- Imports custom types from `lib/types.nix` for structured option records (MIDI devices, audio connections).
- Calls script builder functions from `packages/boot-scripts/default.nix` and `packages/supercollider-scripts/default.nix` to produce derivations — it does **not** inline script content.
- When `helpers.installScripts = true`, generates the following as `pkgs.writeShellScriptBin` entries added to `home.packages`:
  - `install-superdirt`
  - `start-superdirt`
  - `tidal-repl`
  - `sclang`

### Editing Guidelines

- Use `lib.` prefix explicitly everywhere — **no `with lib;`**.
- Prefer `lib.mkMerge` for assembling conditional config blocks.
- Use `lib.optionalAttrs` instead of bare `if-then-else {}` for optional attribute sets.
- Use `lib.filterAttrs` to strip null/empty values before merging.
- Keep option declarations and `config` definitions clearly separated.
- Platform branches should be isolated to the smallest possible scope — do not wrap entire `config` blocks in `if isDarwin`.

## `modules/nixos/audio.nix`

System-level audio configuration (PipeWire, JACK, ALSA settings). Currently future/optional — it is not wired into the default exports and users must import it explicitly if needed. Do not add it to `modules/nixos/default.nix` without a clear use-case.
