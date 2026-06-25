# CLAUDE.md

Guidelines for working in this repository.

## What This Repo Does

Cross-platform desktop setup for macOS, Ubuntu, and Windows using Ansible.
Running the install playbook produces an idempotent, fully-configured machine from scratch.

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
    runtimes/            # Installs nvm/uv/rustup, Node/Python/Rust, global cargo/pip packages
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

- **Platform detection** uses `effective_platform` (set in `install.yml` pre_tasks): `darwin`, `debian`, or `windows`.
Always use this variable, not raw `ansible_os_family`, in role conditionals.
- **Per-platform vars** live in `roles/<role>/vars/{darwin,debian,windows}.yml`. Cross-platform vars live in `ansible/inventory/group_vars/all.yml`.
- **`roles_path`** is set to `ansible/roles` in `ansible.cfg` — use role names directly, not paths.
- **Prefer `~/.local/bin`** over `/usr/local/bin` for user scripts. Avoids `become: true`.
- **Shell tasks over `ansible.builtin.pip`** — the system Python uses PEP 668. Use `uv tool install` for Python tools instead.
- **`changed_when: false`** on shell tasks that are inherently idempotent (installs that check before acting, `cargo install`, etc.).

## Ansible Collections

`community.general` and `community.windows` — installed via:

```sh
ansible-galaxy collection install -r ansible/requirements.yml
```

## Adding a New Tool

Touch **all** of these files — none are optional:

1. **`roles/tools/vars/{darwin,debian,windows}.yml`** — add the package name to the appropriate platform list(s).
   Use WinGet IDs for Windows (e.g. `MikeFarah.yq`). Lists are alphabetically sorted.
2. **`ansible/playbooks/verify.yml`** — add a `--version` entry to `tools_to_verify` (Unix)
   **and** `windows_tools_to_verify` (Windows) if cross-platform.
3. **`README.md` table row** — add a row to the Tools table.
   **Before inserting, check the README Table Alignment rules below.**
4. **`README.md` link reference** — add `[tool-name]: https://...` in the alphabetically sorted reference block at the bottom.
5. **`cspell.yaml`** — add any non-dictionary words. Real product/tool names go in `words`;
   code identifiers, config keys, and handles (e.g. WinGet IDs, author handles) go in `ignoreWords`.
   Keep both lists sorted case-insensitively.
6. **`roles/dotfiles/tasks/main.yml`** — if the tool requires shell activation (e.g. sourcing a `.sh` file
   or setting an env var), add `lineinfile` tasks here.

If the tool is only available via a custom installer on a platform, also add a check-and-install task to `roles/tools/tasks/{darwin,debian,windows}.yml`.

## Adding a New MCP Server

MCP servers are configured at user scope via `claude mcp add`. The list lives in
`ansible/inventory/group_vars/all.yml` under `mcp_servers`; a single loop task in
`roles/dotfiles/tasks/main.yml` iterates over it.

`claude mcp add` exits 1 if the server already exists, so the loop task pre-checks
with `claude mcp list | grep -q` before running — do not remove this guard.

To add a new MCP server:

1. **`ansible/inventory/group_vars/all.yml`** — append to `mcp_servers` (alphabetically):

   ```yaml
   - name: my-server
     command: npx @scope/my-mcp-package
   ```

2. **`cspell.yaml`** — add any non-dictionary words (package scope → `ignoreWords`, server name per the words/ignoreWords split).

No changes to the dotfiles task or verify playbook are needed.

## Adding a New App

1. **`roles/apps/vars/{darwin,debian,windows}.yml`** — add the package name.
2. **`README.md` table row** — add a row to the Apps table. **Check column widths first (see README Table Alignment below).**
3. **`README.md` link reference** — add the link reference in the sorted block at the bottom.
4. **`cspell.yaml`** — add any non-dictionary words (`words` vs `ignoreWords` per the split).

## README Table Alignment

Tables use the `aligned` style enforced by markdownlint. Violating this always causes a full-column rewrite.
**Check before inserting any row:**

1. Measure the proposed link text including brackets (e.g. `[zsh-syntax-highlighting]` = 25 chars).
2. Compare against the current column 1 content width: count the characters between the leading and trailing
   space inside the pipes on any existing row.
3. If the new text would exceed that width, **expand every row and the separator in that column first**, then add the new row.

The separator line must match: `| ---...--- |` with the same number of dashes as the content width.

## Keeping README Tables Accurate

After any change that affects which platforms a tool or app is installed on, review the Tools,
Apps, Runtimes, and Cross-Platform Packages tables in `README.md` and update the Platforms column
to match the actual vars files:

- `roles/tools/vars/{darwin,debian,windows}.yml` — per-platform CLI tools
- `roles/apps/vars/{darwin,debian,windows}.yml` — per-platform GUI apps
- `ansible/inventory/group_vars/all.yml` — cross-platform cargo/pip/pnpm packages

Use "all" only when the item genuinely appears in all three platform files (or in `all.yml` with platform-agnostic installation).

## Docs

- `docs/principles.md` — architecture principles; update when a new cross-cutting decision is made.
- `docs/adr/` — one file per decision, numbered sequentially. ADRs are append-only; supersede rather than delete.
