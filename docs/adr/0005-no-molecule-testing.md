# ADR-0005: No Molecule role testing

**Status:** Accepted
**Date:** 2026-02-23

## Context

Molecule is the standard testing framework for Ansible roles. It provisions
ephemeral containers or VMs, applies a role, and runs assertions to verify
the outcome. The repository already targets production-quality automation
(principle 13) and uses CI for linting. The question is whether role-level
integration tests via Molecule would add meaningful value.

## Options considered

| Option                                    | Notes                                                                                                          |
| ----------------------------------------- | -------------------------------------------------------------------------------------------------------------- |
| **Molecule with Docker**                  | Standard approach; containers are fast and disposable; requires systemd for many tasks; macOS roles untestable |
| **Molecule with VM drivers**              | Can test macOS via Lima or Vagrant; slow; heavy CI requirements; significant setup cost                        |
| **No Molecule; rely on existing tooling** | ansible-lint, shellcheck, verify.yml, and idempotent re-runs cover the realistic failure modes                 |

## Decision

Do **not** introduce Molecule at this time.

## Rationale

**Most roles cannot run in a container.** Molecule's primary driver is
Docker. The majority of what this repository does is incompatible with
a headless container environment:

- Homebrew only runs on macOS — no Docker image exists for it
- `community.general.osx_defaults` and all macOS system configuration
  requires a real macOS host
- Snap packages require `systemd`, which is not available in standard
  Docker containers
- GUI applications (VS Code, Firefox, Ghostty, Obsidian) cannot install
  headlessly
- WinGet requires a Windows host
- Interactive tools (lazygit, zoxide shell init, zsh-autosuggestions)
  require a real shell session to be meaningfully exercised

**The roles are not designed for isolation.** Molecule tests roles
independently, but this repository's roles are explicitly ordered by
dependency: `bootstrap` → `runtimes` → `tools` → `apps` → `dotfiles`
→ `git` → `os_config`. The `tools` role assumes Mise shims are present
(from `runtimes`); the `dotfiles` role references binaries installed by
`tools`. Meaningful isolated testing would require significant mocking.

**Existing tooling already covers the realistic failure modes:**

| Risk                                               | Mitigated by                                                  |
| -------------------------------------------------- | ------------------------------------------------------------- |
| Unsafe shell patterns, missing idempotency markers | `ansible-lint` at `production` profile in CI                  |
| Shell script bugs                                  | `shellcheck` in pre-commit and CI                             |
| YAML syntax errors                                 | `yamllint` in pre-commit and CI                               |
| Broken tool installs                               | `verify.yml` smoke tests every installed binary               |
| Unexpected changes on re-run                       | Idempotent design; `just dry-run` for preview                 |
| macOS defaults not applying                        | `community.general.osx_defaults` reports true `changed` state |

The most honest integration test for a desktop setup is running
`just install` twice on a real machine. The repository's design already
supports and requires this.

## Consequences

**Positive:**

- No additional framework, configuration, or CI infrastructure to maintain.
- CI remains fast — linting runs in seconds rather than minutes.
- No false confidence from tests that mock the interesting behaviour.

**Negative / tradeoffs:**

- Role logic is not automatically exercised against a clean OS image in CI.
- A syntax error in a platform-specific task file (e.g. a Windows task that
  has never been run) could go undetected until a real install attempt.

## Revisit if

- The repository evolves into a shared Ansible collection published to
  Ansible Galaxy, where strangers run roles against unknown environments.
- Roles are extracted that genuinely run headlessly (e.g. a pure dotfile
  deployment role with no package dependencies).
- The repository is used to configure a fleet of machines where a broken
  role could affect many people simultaneously.
