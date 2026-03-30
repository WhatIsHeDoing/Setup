# ADR-0006: Tech-specific runtime managers replacing Mise

**Status:** Accepted
**Date:** 2026-03-26
**Supersedes:** [ADR-0002](0002-mise-as-runtime-version-manager.md)

## Context

ADR-0002 adopted Mise as a single universal runtime version manager across all
three platforms. In practice, Mise has proven problematic as a global install:

- Global Mise installations interact poorly with project-level `.mise.toml` files
  and with tools that expect the canonical version manager for their ecosystem.
- Shell activation (`eval "$(mise activate zsh)"`) adds latency and occasionally
  breaks in non-interactive shells and CI environments.
- Each language ecosystem now ships a best-in-class dedicated tool — nvm for Node,
  uv for Python — that is faster, more reliable, and better maintained than the
  corresponding Mise plugin.
- Rustup was always the authoritative Rust toolchain manager; Mise was only
  wrapping it.

## Decision

Replace Mise with the canonical tool for each runtime:

| Runtime | Tool        | Install method (macOS/Ubuntu)                | Install method (Windows)    |
| ------- | ----------- | -------------------------------------------- | --------------------------- |
| Node.js | **nvm**     | Homebrew / official `nvm` install script     | `CoreyButler.NVMforWindows` |
| Python  | **uv**      | Homebrew / official `astral.sh/uv` installer | `astral-sh.uv`              |
| Rust    | **rustup**  | Official `sh.rustup.rs` installer            | `Rustlang.Rustup` (WinGet)  |

Additional conventions:

- `nvm install --lts && nvm alias default lts/*` is used to install and pin the
  active Node version on macOS and Ubuntu.
- `uv python install` downloads the latest managed Python. Python tools from
  `pip_packages` are installed with `uv tool install`, giving each tool an
  isolated virtualenv and placing its CLI at `~/.local/bin/`.
- `pip` and `setuptools` are removed from `pip_packages`; uv handles packaging
  infrastructure automatically.
- `ipykernel` is installed as a uv tool for VS Code Jupyter support; for
  project-specific kernels use `uv venv` and register the kernel with
  `python -m ipykernel install`.
- `pnpm` is installed via Homebrew on macOS, the standalone pnpm installer on
  Ubuntu, and WinGet on Windows. It is no longer managed via Mise or Node.
- The root-level `.mise.toml` has been deleted.

## Consequences

**Positive:**

- Each tool is managed by the community that knows it best, with faster bug fixes
  and better documentation.
- No universal shim layer means fewer mysterious PATH or activation failures.
- `uv` is significantly faster than pip for package installation and resolves
  dependencies more reliably.
- nvm's `lts/*` alias makes it straightforward to stay on the latest LTS Node.
- Shell startup no longer requires `eval "$(mise activate zsh)"`.

**Negative / tradeoffs:**

- Three separate tools to learn rather than one.
- nvm is a shell function, not a binary; Ansible tasks that need Node must source
  `nvm.sh` explicitly.
- The `nvm` version pinned in the Ubuntu install script
  (`nvm/v0.40.3/install.sh`) must be updated manually when a new nvm release
  ships. Update the version in `ansible/roles/runtimes/tasks/main.yml`.
