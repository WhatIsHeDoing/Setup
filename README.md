# Setup

[![Lint](https://github.com/WhatIsHeDoing/Setup/actions/workflows/lint.yml/badge.svg)](https://github.com/WhatIsHeDoing/Setup/actions/workflows/lint.yml)
[![Install](https://github.com/WhatIsHeDoing/Setup/actions/workflows/install.yml/badge.svg)](https://github.com/WhatIsHeDoing/Setup/actions/workflows/install.yml)
[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE.md)
[![Security Policy](https://img.shields.io/badge/security-policy-informational.svg)](SECURITY.md)

Cross-platform desktop setup using [Ansible], [nvm], [uv], and [rustup].

Targets **macOS**, **Ubuntu**, and **Windows** (via WSL2). Idempotent — run at any time to install missing tools or apply updates.

## How It Works

| Layer            | Tool                                 | Role                                               |
| ---------------- | ------------------------------------ | -------------------------------------------------- |
| Orchestrator     | [Ansible]                            | Idempotent install, config, and dotfile deployment |
| Runtimes         | [nvm] / [uv] / [rustup]              | Node, Python, Rust version management              |
| Package managers | Homebrew / apt+snap+flatpak / WinGet | Platform-native package installation               |

Ansible runs locally on macOS and Ubuntu (`connection: local`).
On Windows, it runs from WSL2 and connects to the Windows host over WinRM using the WSL2 gateway address.

## Quick Start

### 1. Bootstrap

Run once on a fresh machine to install the prerequisites Ansible and Just on all platforms, and Git for Windows:

```sh
# macOS
bash bootstrap/bootstrap_macos.sh

# Ubuntu / WSL2
bash bootstrap/bootstrap_ubuntu.sh

# Windows — run first in PowerShell as Administrator
.\bootstrap\bootstrap_windows.ps1
```

### 2. Install

```sh
just install
```

### 3. Upgrade

```sh
just upgrade
```

### Dry run

Preview exactly what `just install` would change without touching the machine:

```sh
just dry-run
```

Runs the playbook with `--check --diff`: shows which tasks would make changes and diffs any file content that would be modified.
The verification step is skipped because commands do not actually execute in check mode.

### Running a subset

Each role is tagged so you can re-run it without running the full playbook:

| Tag         | Role                                      |
| ----------- | ----------------------------------------- |
| `bootstrap` | Package manager setup                     |
| `runtimes`  | Node, Python, Rust, global packages       |
| `tools`     | CLI tools                                 |
| `apps`      | GUI applications                          |
| `dotfiles`  | Config files and scripts                  |
| `git`       | Global git configuration                  |
| `os_config` | VS Code extensions, macOS system defaults |

```sh
just install-tags dotfiles              # redeploy config files only
just install-tags git                   # reapply git config (e.g. after editing local.yml)
just install-tags dotfiles git          # multiple roles at once
just dry-run-tags dotfiles              # preview config file changes only
just dry-run-tags git                   # preview git config changes only
```

## Windows Setup

Windows packages are managed from WSL2 via Ansible + WinRM. The flow is:

1. Run `bootstrap\bootstrap_windows.ps1` in PowerShell as Administrator — installs Git, configures WinRM, sets up WSL2.
2. In WSL2, clone this repo and run `bash bootstrap/bootstrap_ubuntu.sh` (installs Ansible).
3. Run the install command above with the `windows.yml` inventory.

The Ansible playbook connects back to the Windows host over WinRM and installs everything via WinGet.

## Repo Structure

```txt
.
├── ansible/
│   ├── inventory/
│   │   ├── group_vars/all.yml         # Cross-platform vars (git config, cargo/pip packages)
│   │   ├── group_vars/local.yml.example  # Template for gitignored personal overrides
│   │   ├── localhost.yml        # macOS / Ubuntu target
│   │   └── windows.yml         # Windows target (WinRM via WSL2 gateway)
│   ├── playbooks/
│   │   ├── install.yml          # Main install playbook (runs verify at end)
│   │   ├── upgrade.yml          # Upgrade all packages
│   │   └── verify.yml           # Verify tools are installed
│   ├── requirements.yml         # Ansible Galaxy collections
│   └── roles/
│       ├── bootstrap/           # Package manager setup (Homebrew, apt repos, WinGet)
│       ├── runtimes/            # Node, Python, Rust via nvm, uv, rustup
│       ├── tools/               # CLI tools
│       ├── apps/                # GUI applications
│       ├── dotfiles/            # Config file and script deployment
│       ├── git/                 # Git global configuration
│       └── os_config/           # OS-level config (VS Code extensions, Docker group, etc.)
├── bootstrap/
│   ├── bootstrap_macos.sh       # Installs Homebrew, Ansible
│   ├── bootstrap_ubuntu.sh      # Installs pipx, Ansible
│   └── bootstrap_windows.ps1   # Installs Git, configures WinRM, sets up WSL2
├── config/
│   ├── starship.toml            # Starship prompt config
│   └── bottom.toml              # bottom system monitor config
├── docs/
│   ├── principles.md            # Architecture principles
│   └── adr/                     # Architecture Decision Records
├── scripts/
│   ├── ff                       # Fuzzy-find script (macOS, Ubuntu)
│   └── ll                       # Colourful directory listing (macOS, Ubuntu)
└── Justfile                     # Convenience wrappers around ansible-playbook
```

## What Gets Installed

`all` means macOS, Ubuntu, and Windows.

### Runtimes

| Runtime      | Platforms       | Manager                                                             |
| ------------ | --------------- | ------------------------------------------------------------------- |
| [Node.js]    | all             | nvm (macOS/Ubuntu), nvm-windows (Windows)                           |
| [Python]     | all             | uv (macOS/Ubuntu), WinGet (Windows)                                 |
| [Rust]       | all             | rustup (macOS/Ubuntu), WinGet/rustup (Windows)                      |
| [.NET]       | all             | Homebrew (macOS), apt (Ubuntu), WinGet (Windows)                    |
| [Docker]     | all             | OrbStack (macOS), apt (Ubuntu), Docker Desktop via WinGet (Windows) |
| [PowerShell] | Ubuntu, Windows | apt (Ubuntu), WinGet (Windows)                                      |

### Tools

| Tool                      | Platforms      | Description                                       |
| ------------------------- | -------------- | ------------------------------------------------- |
| [asciinema]               | macOS, Ubuntu  | Record and share terminal sessions                |
| [atuin]                   | macOS          | Shell history with sync and interactive search    |
| [bat]                     | all            | `cat` clone with syntax highlighting              |
| [bottom]                  | all            | Terminal system monitor                           |
| [delta]                   | all            | Syntax-highlighted diffs; configured as git pager |
| [dust]                    | macOS          | Intuitive disk usage viewer                       |
| [duti]                    | macOS          | Set default file-type handler associations        |
| [exiftool]                | all            | Read and write image and media metadata           |
| [eza]                     | all            | Modern `ls` replacement                           |
| [fd]                      | all            | Fast and user-friendly `find` alternative         |
| [fzf]                     | all            | Command-line fuzzy finder                         |
| [gh]                      | all            | GitHub CLI                                        |
| [Git LFS]                 | all            | Git Large File Storage                            |
| [gitleaks]                | all            | Secret scanner for git repositories               |
| [graphviz]                | all            | Graph visualization via the DOT language          |
| [jq]                      | all            | `sed` for JSON                                    |
| [just]                    | all            | Task runner                                       |
| [lazygit]                 | all            | TUI for git                                       |
| [lefthook]                | all            | Fast, polyglot git hooks manager                  |
| [less]                    | all            | Terminal pager                                    |
| [markdownlint-cli2]       | macOS          | Markdown linter and formatter                     |
| [miller]                  | all            | Swiss Army knife for tabular data (CSV/JSON/TSV)  |
| [pandoc]                  | all            | Universal markup converter                        |
| [pnpm]                    | all            | Fast JavaScript package manager                   |
| [poppler]                 | macOS, Ubuntu  | PDF rendering library and CLI utilities           |
| [ripgrep]                 | all            | Fast regex search                                 |
| [ripgrep-all]             | all            | ripgrep across PDFs, Office docs, etc.            |
| [shellcheck]              | all            | Shell script linter                               |
| [shfmt]                   | all            | Shell script formatter                            |
| [Starship]                | all            | Cross-shell prompt                                |
| [svgo]                    | macOS          | SVG optimizer                                     |
| [taplo]                   | macOS, Ubuntu  | TOML toolkit (format and lint)                    |
| [tlrc]                    | macOS          | Community tldr pages client                       |
| [UPX]                     | all            | Executable packer                                 |
| [vale]                    | macOS, Windows | Prose linter for docs and Markdown                |
| [yq]                      | all            | YAML/JSON/XML processor (jq for YAML)             |
| [zoxide]                  | all            | Smarter `cd` that learns your habits              |
| [zsh-autocomplete]        | macOS          | Real-time tab completion for Zsh                  |
| [zsh-autosuggestions]     | macOS          | Fish-style history suggestions for Zsh            |
| [zsh-syntax-highlighting] | macOS          | Fish-style syntax highlighting for Zsh            |
| [NuGet]                   | all            | .NET package manager                              |
| [PuTTY]                   | Windows        | SSH client                                        |
| [VS Build Tools]          | Windows        | MSVC compiler toolchain                           |
| [Docker] (apt)            | Ubuntu         | Container runtime                                 |
| [Flatpak]                 | Ubuntu         | Application distribution                          |
| [ffmpeg]                  | all            | Media processing                                  |

### Apps

| App                        | Platforms       | Description                                           |
| -------------------------- | --------------- | ----------------------------------------------------- |
| [Claude Code]              | all             | AI coding assistant CLI and desktop app               |
| [VS Code]                  | all             | Code editor                                           |
| [draw.io]                  | all             | Diagramming                                           |
| [Obsidian]                 | all             | Note-taking                                           |
| [Spotify]                  | all             | Music                                                 |
| [Telegram]                 | all             | Messaging                                             |
| [ghostty]                  | macOS, Ubuntu   | Fast, native terminal emulator                        |
| [JetBrains Mono Nerd Font] | macOS           | Nerd Font for terminal icons (Starship, eza, etc.)    |
| [OrbStack]                 | macOS           | Container and VM runtime (Docker Desktop replacement) |
| [Raindrop.io]              | macOS, Windows  | Bookmark manager                                      |
| [7-Zip]                    | Windows         | File archiver                                         |
| [Caesium]                  | Ubuntu, Windows | Image compressor                                      |
| [DBeaver]                  | all             | Universal database tool                               |
| [Amberol]                  | Ubuntu          | Music player                                          |
| [Firefox]                  | all             | Web browser                                           |
| [Raycast]                  | macOS           | Launcher, window manager, clipboard history           |
| [AlDente]                  | macOS           | Battery charge limiter                                |
| [Ice]                      | macOS           | Menu bar manager                                      |

### Cross-Platform Packages

Installed on all platforms via their respective package managers:

| Type    | Packages                                                                         |
| ------- | -------------------------------------------------------------------------------- |
| Cargo   | `cargo-modules`, `cargo-outdated`, `cargo-update`, `diskonaut`, `wasm-pack`      |
| pip     | `ansible-core`, `ansible-lint`, `checkov`, `commitizen`, `ipykernel`, `yamllint` |
| pnpm    | `cspell`                                                                         |
| VS Code | GitLens, EditorConfig, Markdownlint, Night Owl theme, VS Code Icons              |

### Scripts

Deployed to `~/.local/bin` on macOS and Ubuntu:

| Command     | Description                                                  |
| ----------- | ------------------------------------------------------------ |
| `ff <term>` | Fuzzy find files matching a search term, previewed with bat  |
| `ll [path]` | List files with eza (long format, git-aware, human-readable) |

## Post-Install (macOS)

Most settings are applied automatically by the `os_config` role, but a few can
only be changed through the GUI.

### Use Raycast instead of Spotlight

[Raycast] is installed as a cask, but macOS keeps ⌘ Space bound to Spotlight, so
the shortcut must be reassigned by hand:

1. **Free the shortcut from Spotlight** — open **System Settings → Keyboard →
   Keyboard Shortcuts… → Spotlight** and turn off **Show Spotlight search**
   (and, if you like, **Show Finder search window**).
2. **Launch Raycast** once from Applications and finish its first-run setup.
3. **Bind the shortcut to Raycast** — in **Raycast → Settings → General →
   Raycast Hotkey**, click the field and press ⌘ Space.

Raycast now opens on ⌘ Space, putting search, app launching, clipboard history,
and window management in one place. Spotlight still works from its menu-bar icon
if you ever need it.

## Customisation

Machine-specific settings that should not be committed live in a gitignored file:

```sh
cp ansible/inventory/group_vars/local.yml.example ansible/inventory/group_vars/local.yml
```

Edit `local.yml` and fill in your details:

```yaml
git_user_name: "Your Name"
git_user_email: "you@example.com"
```

Ansible picks this file up automatically. If it is absent the identity tasks are skipped — nothing breaks.
The `.example` file documents the available options.

## Documentation

- [docs/principles.md](docs/principles.md) — Architecture principles guiding tool and approach choices
- [docs/adr/](docs/adr/) — Architecture Decision Records

## Testing

Install the git hooks once, then run the full check gate:

```sh
just hooks
just check
```

[.NET]: https://dotnet.microsoft.com/
[7-Zip]: https://7-zip.org/
[AlDente]: https://apphousekitchen.com/
[Amberol]: https://gitlab.gnome.org/World/amberol
[Ansible]: https://www.ansible.com/
[asciinema]: https://asciinema.org/
[atuin]: https://atuin.sh/
[bat]: https://github.com/sharkdp/bat
[bottom]: https://clementtsang.github.io/bottom/
[Caesium]: https://saerasoft.com/caesium
[Claude Code]: https://claude.ai/code
[DBeaver]: https://dbeaver.io/
[delta]: https://dandavison.github.io/delta/
[Docker]: https://www.docker.com/
[draw.io]: https://www.drawio.com/
[dust]: https://github.com/bootandy/dust
[duti]: https://github.com/moretension/duti
[exiftool]: https://exiftool.org/
[eza]: https://github.com/eza-community/eza
[fd]: https://github.com/sharkdp/fd
[ffmpeg]: https://ffmpeg.org/
[Firefox]: https://www.mozilla.org/firefox/
[Flatpak]: https://flatpak.org/
[fzf]: https://github.com/junegunn/fzf
[ghostty]: https://ghostty.org/
[gh]: https://cli.github.com/
[Git LFS]: https://git-lfs.com/
[gitleaks]: https://github.com/gitleaks/gitleaks
[graphviz]: https://graphviz.org/
[Ice]: https://github.com/jordanbaird/Ice
[JetBrains Mono Nerd Font]: https://www.nerdfonts.com/
[jq]: https://jqlang.github.io/jq/
[just]: https://just.systems/
[lazygit]: https://github.com/jesseduffield/lazygit
[lefthook]: https://lefthook.dev/
[less]: https://www.greenwoodsoftware.com/less/
[markdownlint-cli2]: https://github.com/DavidAnson/markdownlint-cli2
[miller]: https://miller.readthedocs.io/
[Node.js]: https://nodejs.org/
[NuGet]: https://www.nuget.org/
[nvm]: https://github.com/nvm-sh/nvm
[Obsidian]: https://obsidian.md/
[OrbStack]: https://orbstack.dev/
[pandoc]: https://pandoc.org/
[pnpm]: https://pnpm.io/
[poppler]: https://poppler.freedesktop.org/
[PowerShell]: https://github.com/PowerShell/PowerShell
[PuTTY]: https://putty.org/
[Python]: https://www.python.org/
[Raindrop.io]: https://raindrop.io/
[Raycast]: https://www.raycast.com/
[ripgrep-all]: https://github.com/phiresky/ripgrep-all
[ripgrep]: https://github.com/BurntSushi/ripgrep
[rustup]: https://rustup.rs/
[Rust]: https://www.rust-lang.org/
[shellcheck]: https://www.shellcheck.net/
[shfmt]: https://github.com/mvdan/sh
[Spotify]: https://open.spotify.com/
[Starship]: https://starship.rs/
[svgo]: https://github.com/svg/svgo
[taplo]: https://taplo.tamasfe.dev/
[Telegram]: https://telegram.org/
[tlrc]: https://github.com/tldr-pages/tlrc
[UPX]: https://upx.github.io/
[uv]: https://docs.astral.sh/uv/
[vale]: https://vale.sh/
[VS Build Tools]: https://visualstudio.microsoft.com/visual-cpp-build-tools/
[VS Code]: https://code.visualstudio.com/
[yq]: https://github.com/mikefarah/yq
[zoxide]: https://github.com/ajeetdsouza/zoxide
[zsh-autocomplete]: https://github.com/marlonrichert/zsh-autocomplete
[zsh-autosuggestions]: https://github.com/zsh-users/zsh-autosuggestions
[zsh-syntax-highlighting]: https://github.com/zsh-users/zsh-syntax-highlighting
