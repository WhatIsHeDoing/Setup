# ADR-0002: Mise as universal runtime version manager

**Status:** Accepted
**Date:** 2026-02-21

## Context

The repository currently manages language runtimes through a combination of
separate, purpose-built version managers:

- Node.js via the system package manager or nvm
- Python via the system package manager or pyenv
- Rust via rustup

Each tool has its own installation method, configuration file format, shell
integration, and upgrade path. This multiplies maintenance cost, creates
inconsistent behaviour across platforms, and produces per-project configuration
that is spread across multiple dotfiles (`.nvmrc`, `.python-version`, etc.).

A single tool that manages all runtime versions, integrates with the shell
uniformly, and works across all three target platforms would reduce this
complexity significantly.

## Options considered

| Option                              | Notes                                                                                                                                                                                            |
| ----------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Mise**                            | Written in Rust; fast; single `.mise.toml` per project; backward-compatible with asdf `.tool-versions`; supports Node, Python, Rust, and most other runtimes; works on macOS, Linux, and Windows |
| **asdf**                            | The tool Mise was forked from; same plugin model; slower (shell script); less active development                                                                                                 |
| **Nix / devenv**                    | Fully reproducible environments; steeper learning curve; ties runtime management to the broader Nix ecosystem                                                                                    |
| **Keep existing tools**             | No migration cost; but retains the fragmentation described in the context above                                                                                                                  |
| **Language-specific managers only** | nvm, pyenv, rustup independently; the status quo; doesn't solve the consistency problem                                                                                                          |

## Decision

Use **Mise** as the single runtime version manager across all platforms,
replacing nvm, pyenv, and direct rustup usage for version selection.

- A root-level `.mise.toml` in this repository declares the default tool
  versions for the setup environment itself.
- Individual projects may have their own `.mise.toml` for project-local
  overrides.
- Mise is installed as part of the bootstrap step on each platform and
  activated in the shell profile.
- `rustup` is retained for Rust toolchain component management (e.g.
  `rust-analyzer`, `wasm32` targets) but Mise selects the active Rust version.

## Consequences

**Positive:**

- One tool, one config format, one shell integration across all runtimes.
- `.mise.toml` is a single source of truth for which runtime versions are
  active in a given directory.
- Backward-compatible with asdf plugins, giving access to a large plugin
  ecosystem.
- Fast activation (written in Rust); negligible shell startup overhead.
- Cross-platform: works on macOS, Ubuntu, and Windows (via Git Bash or WSL2).

**Negative / tradeoffs:**

- Adds Mise itself as a prerequisite that must be installed before runtimes.
- Developers familiar with nvm or pyenv must learn a new tool.
- Plugin availability for less common runtimes may lag behind asdf.
- On Windows, native support is available but the experience is smoothest
  under WSL2.
