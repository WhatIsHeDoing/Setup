# ADR-0004: Dotfile management via Ansible

**Status:** Accepted
**Date:** 2026-02-21

## Context

The repository contains configuration files that must be deployed to the
correct locations on each platform:

- `config/starship.toml` → `~/.config/starship.toml` (all platforms)
- `powershell-profile.ps1` → the path returned by `$PROFILE` (Windows)

A mechanism is needed to copy or link these files to their destinations
idempotently as part of the setup process.

## Options considered

| Option                            | Notes                                                                                                                                      |
| --------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| **Ansible copy/template modules** | Uses the existing orchestrator; no additional tool; files stay in this repo; handles platform-specific destination paths via variables     |
| **chezmoi**                       | Purpose-built dotfile manager; excellent cross-platform support; handles secret injection into templates; adds a new tool and mental model |
| **GNU Stow**                      | Creates symlinks via a simple convention; no additional config; does not work natively on Windows                                          |
| **Bare git repo**                 | Tracks dotfiles directly in `$HOME`; no extra tool; awkward with multiple machines and platforms                                           |
| **Separate dotfiles repo**        | Clean separation of concerns; standard pattern for public dotfiles; splits configuration across two repos to maintain                      |

## Decision

Manage dotfiles via **Ansible's `copy` and `template` modules**, deploying
them from this repository to their correct per-platform destinations.

- Configuration files live in `files/` (static) or `templates/` (platform-
  variable) within the relevant Ansible role.
- Destination paths are defined as role variables, allowing platform-specific
  overrides (e.g. `~/.config/starship.toml` on Linux/macOS vs
  `%APPDATA%\starship\starship.toml` on Windows) without duplicating files.
- Ansible's `copy` module is idempotent by default; files are only written
  when content has changed.
- The `template` module is used where a config file needs minor per-platform
  differences that do not warrant maintaining separate copies.

This approach is deferred if secret injection into config files becomes a
requirement, at which point chezmoi is the recommended migration path.

## Consequences

**Positive:**

- One repo, one tool, one mental model — dotfiles are managed alongside the
  rest of the setup rather than in a separate system.
- Ansible's idempotency guarantees apply to dotfile deployment automatically.
- Platform-specific destination paths are handled by Ansible variables,
  keeping the config files themselves platform-agnostic.
- No additional tool to install or learn.

**Negative / tradeoffs:**

- Ansible is not optimised for dotfile management; a dedicated tool like
  chezmoi would offer better ergonomics for complex templating or secret
  injection.
- Config files must be manually copied into the Ansible role structure
  (`files/` or `templates/`) rather than living at the repo root, which is
  a minor structural change from the current layout.
- If dotfiles are ever extracted to a public repo, they would need to be
  split out from the Ansible roles.
