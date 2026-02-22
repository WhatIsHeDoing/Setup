# CLAUDE.md

Guidelines for working in this repository.

## What This Repo Does

Cross-platform desktop setup for macOS, Ubuntu, and Windows using Ansible and Mise. Running the install playbook produces an idempotent, fully-configured machine from scratch.

## Running the Setup

```sh
# macOS / Ubuntu
ansible-playbook ansible/playbooks/install.yml \
    -i ansible/inventory/localhost.yml \
    -e "repo_root=$(pwd)"
```

The `Justfile` provides convenience wrappers for the same commands.

## Repo Layout

```txt
ansible/
  inventory/
    group_vars/all.yml   # Cross-platform vars: cargo_packages, pip_packages, vscode_extensions
    localhost.yml        # macOS / Ubuntu inventory
    windows.yml          # Windows inventory (WinRM from WSL2)
  playbooks/
    install.yml          # Main playbook; imports verify.yml at end
    upgrade.yml          # Upgrades all packages/tools
    verify.yml           # Smoke-tests every installed tool
  roles/
    bootstrap/           # Installs package managers (Homebrew, apt repos, WinGet)
    runtimes/            # Installs Mise, Node/Python/Rust, global cargo/pip packages
    tools/               # CLI tools per platform
    apps/                # GUI apps per platform
    dotfiles/            # Deploys config files and scripts/ to ~/.local/bin
    git/                 # Global git config and git-lfs init
    os_config/           # VS Code extensions, Docker group, OS preferences
bootstrap/
  bootstrap_macos.sh     # Installs Homebrew + Ansible (run once)
  bootstrap_ubuntu.sh    # Installs pipx + Ansible (run once)
  bootstrap_windows.ps1  # Installs Git, WinRM, WSL2 (run once in PowerShell)
config/                  # starship.toml, bottom.toml
scripts/                 # ff, ll — deployed to ~/.local/bin on macOS and Ubuntu
docs/
  principles.md
  adr/
```

## Key Conventions

- **Platform detection** uses `effective_platform` (set in `install.yml` pre_tasks): `darwin`, `debian`, or `windows`. Always use this variable, not raw `ansible_os_family`, in role conditionals.
- **Per-platform vars** live in `roles/<role>/vars/{darwin,debian,windows}.yml`. Cross-platform vars live in `ansible/inventory/group_vars/all.yml`.
- **`roles_path`** is set to `ansible/roles` in `ansible.cfg` — use role names directly, not paths.
- **Prefer `~/.local/bin`** over `/usr/local/bin` for user scripts. Avoids `become: true`.
- **Shell tasks over `ansible.builtin.pip`** — the system Python uses PEP 668. Use `pip install` via the mise shims PATH instead.
- **`changed_when: false`** on shell tasks that are inherently idempotent (installs that check before acting, `cargo install`, etc.).

## Ansible Collections

`community.general` and `community.windows` — installed via:

```sh
ansible-galaxy collection install -r ansible/requirements.yml
```

## Adding a New Tool

1. Add the package name to the appropriate `roles/tools/vars/{darwin,debian,windows}.yml`.
2. If the tool is only available via a custom installer on a platform, add a check-and-install task to `roles/tools/tasks/{darwin,debian,windows}.yml`.
3. Add a `--version` verification entry to `ansible/playbooks/verify.yml`.
4. Update the Tools table in `README.md`.

## Adding a New App

1. Add the package name to `roles/apps/vars/{darwin,debian,windows}.yml`.
2. Update the Apps table in `README.md`.

## Docs

- `docs/principles.md` — architecture principles; update when a new cross-cutting decision is made.
- `docs/adr/` — one file per decision, numbered sequentially. ADRs are append-only; supersede rather than delete.
