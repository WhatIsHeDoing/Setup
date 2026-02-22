# ADR-0003: Shell scripts as local task runner

**Status:** Superseded (Just replaced by shell scripts)
**Date:** 2026-02-22

## Context

Running setup, upgrades, and verification tasks requires invoking Ansible
playbooks with the correct arguments. Without a task runner, developers must
remember the correct invocation or consult the README.

A previous version of this ADR adopted Just as the task runner. However, Just
must itself be installed before it can be used, meaning it becomes a bootstrap
dependency rather than a product of setup. This adds a mandatory step before
any setup can begin, which conflicts with the principle of minimising the
commands required to reach a working state.

On macOS and Linux, the OS ships with bash; on Windows, PowerShell is always
present. Scripts in these languages require no additional installation.

## Options considered

| Option                      | Notes                                                                                                                                                                        |
| --------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Shell scripts / aliases** | No additional dependency; available immediately on every target OS; logic lives in the same repo as everything else                                                          |
| **Just**                    | Clean recipe format; cross-platform; discoverable via `just --list`; but must be installed as a prerequisite, adding a step before setup can run                             |
| **Make**                    | Universally available on Unix; but designed for build dependency tracking, not task running; tab-sensitivity and implicit behaviour are sources of confusion                 |
| **Task (go-task)**          | YAML-based; cross-platform; more features than Just; adds a Go runtime dependency                                                                                            |
| **npm scripts**             | Convenient if Node is already present; ties task running to the Node ecosystem unnecessarily                                                                                 |

## Decision

Use **shell scripts** (bash on macOS/Linux, PowerShell on Windows) as the
entry points for all common operations.

- `setup_macos.sh`, `setup_ubuntu.sh`, and `setup_windows.ps1` are the
  single entry points on each platform, invokable immediately after a clean
  OS install with no prerequisites.
- Scripts invoke Ansible playbooks rather than implementing logic directly;
  the scripts are the interface, Ansible is the implementation.
- No additional tool needs to be installed before setup can begin.

## Consequences

**Positive:**

- Zero bootstrap dependencies: bash and PowerShell are present on every
  target OS out of the box.
- Fewer steps to reach a working state — running the script is the first
  and only manual action required.
- No layer of indirection between the user and Ansible.

**Negative / tradeoffs:**

- Less discoverable than `just --list`; available operations must be read
  from the README or the scripts themselves.
- Bash and PowerShell scripts diverge in syntax; shared logic cannot be
  expressed in a single file.
- No built-in dependency or ordering semantics between tasks.
