---
description: Flake-parts module context for the flake/ directory
applyTo: "flake/**"
---

## Flake Structure

`flake.nix` uses **flake-parts**. Every `.nix` file under `flake/` is auto-imported — no manual registration needed.

### Files

- `formatters.nix` — treefmt config: alejandra (formatting), deadnix (dead code), statix (lints). All three must pass before a commit.
- `checks.nix` — pre-commit hooks: whitespace trimming, large-file guard, merge-conflict detection, and the treefmt check.
- `devshells.nix` — `nix develop` environment. Provides: nixd (LSP), alejandra, apm-cli. Installs pre-commit hooks on shell entry.
- `actions/` — GitHub Actions workflows generated via actions-nix. **Do NOT hand-edit files under `.github/workflows/`**; edit the Nix source in `actions/` instead and let the generator produce the YAML.
- `packages.nix` — exposes helper scripts (boot-script builders, supercollider-script builders) as named flake packages under `packages.<system>.*`.

## Required Checks Before Committing

```bash
nix fmt          # Run all formatters (alejandra + deadnix + statix)
nix flake check  # Run all checks including pre-commit hooks
```

Both must succeed with no errors or warnings before staging a commit.

## Notes

- Adding a new `.nix` file inside `flake/` is sufficient; import-tree picks it up automatically.
- Keep flake-parts module files focused on a single concern (one file per formatter/checker/shell).
- The `actions/` directory is the single source of truth for CI — never bypass it by editing `.github/workflows/` directly.
