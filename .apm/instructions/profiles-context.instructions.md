---
description: Pre-configured option sets for common TidalCycles use cases
applyTo: "profiles/**"
---

## What Profiles Are

Profiles are **pure attrsets** of `programs.tidalcycles.*` option values. They are not home-manager modules — no `{ config, lib, pkgs, ... }:` function wrapper, no `options`, no `config` key.

A profile file looks like:

```nix
# profiles/standard.nix
{
  programs.tidalcycles = {
    enable = true;
    boot.profile = "standard";
    supercollider.enable = true;
    superdirt.enable = true;
    helpers.installScripts = true;
  };
}
```

Users import a profile and then override individual options on top:

```nix
imports = [ inputs.tidalcycles-nix.profiles.standard ];
programs.tidalcycles.boot.profile = "extended";  # override one option
```

## Available Profiles

| File | Purpose |
|---|---|
| `minimal.nix` | Beginners and low-resource systems — minimal orbits, no MIDI, no OSC |
| `standard.nix` | Recommended defaults — d1-d12, standard SuperDirt, all helper scripts |
| `performance.nix` | Optimized for live performance — larger buffers, higher memory limits |
| `studio.nix` | Full-featured — MIDI, OSC, all helpers enabled, advanced SuperDirt template |

## Rules

- **No module machinery** — profiles must not contain `options`, `config`, `imports` (of other modules), `mkIf`, or `lib.mkMerge`. They are plain attrsets.
- **No side effects** — profiles only set option values; they must not write files or add packages directly.
- **Additive only** — a profile should be a reasonable starting point, not the final word. Always leave room for the user to override.
- **Keep in sync** — when a new `programs.tidalcycles.*` option is added to the module, update affected profiles to include a sensible default for that option.
