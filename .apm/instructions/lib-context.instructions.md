---
description: Custom utilities and types in lib/
applyTo: "lib/**"
---

## Library Layout

`lib/default.nix` exports a single attrset `{ custom, types }` consumed by the module and packages.

### `lib/custom.nix`

Contains general-purpose helpers:

- `scanPaths` — scans a directory and returns a list of paths, used for auto-import patterns throughout the flake.
- `mkBootScript` — takes a `.hs` profile file path and a derivation name; reads the Haskell source and produces a derivation containing the rendered `BootTidal.hs`. Used by `packages/boot-scripts/default.nix`.

### `lib/types.nix`

Defines custom Nix types used in `modules/home-manager/tidalcycles.nix` option declarations:

- `connectionType` — structured type for audio connections (e.g. JACK, PipeWire port pairs).
- `midiDeviceType` — structured record for MIDI device configuration (device name, channel, latency).
- Additional types for other structured option records.

**When to add a new type**: if a module option needs more than 2–3 related fields, define a `lib.types.submodule` (or a custom type) here rather than flattening the fields into the top-level namespace.

## Code Standards

- Use explicit `lib.` prefix throughout — no `with lib;`.
- Types must be composable: prefer `lib.types.listOf myType` over one-off list handling in the module.
- Keep `custom.nix` and `types.nix` free of side effects — pure functions and type definitions only.
- Export everything through `lib/default.nix`; nothing in `lib/` should be imported directly by path from outside `lib/`.
