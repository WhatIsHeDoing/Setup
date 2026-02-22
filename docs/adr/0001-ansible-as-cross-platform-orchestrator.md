# ADR-0001: Ansible as cross-platform orchestrator

**Status:** Accepted
**Date:** 2026-02-21

## Context

The repository currently manages setup through a collection of platform-specific
shell scripts (`setup_macos.sh`, `setup_ubuntu.sh`) and a PowerShell script (`setup_windows.ps1`). While these
scripts share the same intent, they diverge in implementation, structure, and
reliability. Common problems include:

- Idempotency is implemented inconsistently across scripts and must be
  hand-crafted for each step.
- Adding or updating a tool requires changes in multiple scripts with no
  shared abstraction.
- Windows and Linux/macOS scripts are written in different languages, making
  cross-platform reasoning difficult.
- There is no standard way to express "install this package via the appropriate
  manager for this platform" without duplicating conditionals.

A cross-platform orchestration tool is needed that can drive platform-native
package managers, enforce idempotency by design, and provide a single
consistent structure across all target platforms.

## Options considered

| Option                   | Notes                                                                                                                                                                  |
| ------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Ansible**              | Agentless, drives all relevant package managers, idempotent by design, YAML-based, mature Windows support via WinRM                                                    |
| **Nix + Home Manager**   | Highly reproducible and principled; excellent macOS and Linux support via nix-darwin and Home Manager; Windows requires WSL2 and cannot manage native Windows GUI apps |
| **Chef / Puppet / Salt** | Server-oriented configuration management; significant overhead for a single-user desktop setup; requires agents                                                        |
| **PowerShell DSC**       | Windows-only; does not address macOS or Linux                                                                                                                          |
| **Shell scripts + Just** | Current approach extended; idempotency remains manual; cross-platform divergence is structural rather than incidental                                                  |

Nix + Home Manager was seriously considered and is not ruled out for a future
iteration, particularly for macOS and Linux. See ADR-0002 for the decision on
runtime version management, where Nix and Mise overlap.

## Decision

Use **Ansible** as the cross-platform orchestrator for all setup and
maintenance tasks across macOS, Ubuntu, and Windows.

- Platform-specific shell scripts are replaced by Ansible playbooks and roles.
- The existing JSON configuration files (`brew-apps.json`, `scoop-apps.json`)
  become Ansible variable files, preserving the declarative data-as-config
  approach.
- Ansible's built-in package modules (`homebrew`, `apt`, `community.windows.win_scoop`,
  `community.windows.win_winget`) handle platform-specific installation while
  the playbook structure remains consistent.
- Windows is managed via WinRM; macOS and Linux via SSH or local execution.

## Consequences

**Positive:**

- Idempotency is enforced by the tool, not by hand-written conditionals.
- A single playbook structure is readable and maintainable across all platforms.
- Existing JSON configs migrate naturally to Ansible vars with minimal rework.
- The Ansible ecosystem provides modules for most tools used in this repo.
- Roles can be tested independently against a Docker container (Ubuntu), consistent with
  the existing container-based testing approach.

**Negative / tradeoffs:**

- Ansible requires Python on the control node (already present as a runtime).
- Windows managed nodes require WinRM to be configured before first run;
  this is a one-time bootstrap step.
- YAML playbooks are more verbose than equivalent shell commands for simple
  operations.
- The team (currently one person) must learn and maintain Ansible idioms.
