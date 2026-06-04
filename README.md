<h1 align='center'>tidalcycles-nix</h1>
<div align='center'>
  <p>A standalone Nix flake providing a home-manager module for the <a href="https://tidalcycles.org/">TidalCycles</a> live coding environment.</p>
  <a href='https://github.com/DivitMittal/tidalcycles-nix'>
    <img src='https://img.shields.io/github/repo-size/DivitMittal/tidalcycles-nix?&style=for-the-badge&logo=github'>
  </a>
  <a href='https://github.com/DivitMittal/tidalcycles-nix/blob/master/LICENSE'>
    <img src='https://img.shields.io/static/v1.svg?style=for-the-badge&label=License&message=MIT&logo=unlicense'/>
  </a>
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

Manages [TidalCycles](https://tidalcycles.org/) (Haskell), [SuperCollider](https://supercollider.github.io/), and [SuperDirt](https://github.com/musikinformatik/SuperDirt) via home-manager with cross-platform support (NixOS, nix-darwin, standalone).

## Features

- **Boot script profiles** — separate `.hs` files: `minimal`, `standard`, `extended`, `midi`
- **SuperCollider server tuning** — buffers, memory, sample rate, block size
- **MIDI & OSC** — declarative multi-device configuration
- **Pre-built profiles** — `minimal`, `standard`, `performance`, `studio`
- **Helper scripts** — `install-superdirt`, `start-superdirt`, `tidal-repl`, `sclang`
- **Editor integration** — Vim/Neovim, Emacs, VS Code

## Installation

Add to your `flake.nix`:

```nix
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  home-manager.url = "github:nix-community/home-manager";
  tidalcycles-nix.url = "github:DivitMittal/tidalcycles-nix";
};
```

Import the module (pass `inputs` through to your home-manager module):

```nix
imports = [ inputs.tidalcycles-nix.homeManagerModules.default ];
```

Enable in your home configuration:

```nix
programs.tidalcycles = {
  enable = true;
  boot.profile = "standard";
  supercollider.enable = true;
  superdirt.enable = true;
};
```

Then rebuild, install SuperDirt, and start:

```bash
home-manager switch --flake .
install-superdirt       # first-time only
install-sc3-plugins     # macOS only
start-superdirt         # in one terminal
tidal-repl              # in another terminal
```

## Profiles

Drop-in option sets for common setups:

```nix
programs.tidalcycles = inputs.tidalcycles-nix.profiles.standard;  # or minimal / performance / studio
```

Override individual options on top:

```nix
programs.tidalcycles = lib.mkMerge [
  inputs.tidalcycles-nix.profiles.performance
  { boot.orbits = 24; }
];
```

## Configuration examples

### Boot script

```nix
boot = {
  profile = "extended";
  orbits = 16;
  connection = { address = "127.0.0.1"; port = 57120; latency = 0.05; };
  extraFunctions = ''
    let myPattern = fast 2 $ sound "bd sd"
  '';
};
```

### MIDI

```nix
midi = {
  enable = true;
  devices = [
    { name = "Elektron Digitakt"; channels = 16; latency = 0.1; }
    { name = "Novation Circuit";  channels = 16; latency = 0.05; }
  ];
};
```

### SuperCollider server

```nix
supercollider.serverOptions = {
  numBuffers = 1024 * 512;
  memSize    = 8192 * 64;
  maxNodes   = 1024 * 64;
  sampleRate = 48000;
};
```

See [examples/](examples/) for complete working configs and [modules/home-manager/README.md](modules/home-manager/README.md) for full option documentation.

## Platform notes

| Platform | Notes |
|---|---|
| NixOS | SC3-Plugins in nixpkgs; JACK/ALSA audio |
| nix-darwin | SC3-Plugins via `install-sc3-plugins`; CoreAudio |
| Standalone | Any Linux with Nix; manual audio setup |

## Related

- [DivitMittal/OS-nixCfg](https://github.com/DivitMittal/OS-nixCfg) — main Nix configurations
- [TidalCycles docs](https://tidalcycles.org/docs/) · [SuperCollider docs](https://doc.sccode.org/) · [SuperDirt](https://github.com/musikinformatik/SuperDirt) · [home-manager](https://github.com/nix-community/home-manager)
