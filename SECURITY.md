# Security Policy

## Supported Versions

This repository tracks the **latest** versions of all tools and packages.
Only the current `main` branch is actively maintained.

## Reporting a Vulnerability

If you discover a security issue in this repository — such as a credentials
leak, an unsafe shell pattern, or a dependency with a known CVE — please
**do not open a public issue**.

Instead, use [GitHub's private vulnerability reporting](https://github.com/WhatIsHeDoing/Setup/security/advisories/new).

You can expect an acknowledgement within 7 days and a resolution or status
update within 30 days.

## Security Measures

| Layer | Tool | What It Covers |
| --- | --- | --- |
| Secret detection | [gitleaks](https://github.com/gitleaks/gitleaks) | Scans git history for leaked credentials (pre-commit) |
| Filesystem scanning | [Trivy](https://github.com/aquasecurity/trivy) | Secrets and misconfigurations in every push/PR |
| PowerShell analysis | [PSScriptAnalyzer](https://github.com/PowerShell/PSScriptAnalyzer) | Unsafe PowerShell patterns (CI, Windows runner) |
| Ansible linting | [ansible-lint](https://ansible-lint.readthedocs.io/) | Production-profile rules including unsafe shell patterns |
| Shell linting | [shellcheck](https://www.shellcheck.net/) | Shell script bugs and unsafe constructs (pre-commit) |
| Dependency updates | [Renovate](https://github.com/renovatebot/renovate) | Automated PRs for outdated Actions, hooks, and collections |

## Bootstrap Trust Model

The bootstrap scripts download installers over HTTPS (TLS 1.2 minimum).
Users should review the scripts before running them and verify that the
source URLs match the official project repositories:

| Script | Installer | Source |
| --- | --- | --- |
| `bootstrap_macos.sh` | Homebrew | `https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh` |
| `bootstrap_ubuntu.sh` | just | `https://just.systems/install.sh` |

## WinRM Security Note

The Windows bootstrap script enables unencrypted WinRM (`AllowUnencrypted=true`)
for local Ansible control over WSL2. This is intentional and scoped to the
local machine only — see [`bootstrap/bootstrap_windows.ps1`](bootstrap/bootstrap_windows.ps1)
for the full justification. Do not use this configuration on machines reachable
from an untrusted network.
