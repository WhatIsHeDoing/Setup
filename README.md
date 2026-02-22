# Setup

Cross-platform desktop setup using [Ansible] and [Mise].

Targets **macOS**, **Ubuntu**, and **Windows** (via WSL2). Idempotent — run at any time to install missing tools or apply updates.

## How It Works

| Layer            | Tool                                 | Role                                               |
| ---------------- | ------------------------------------ | -------------------------------------------------- |
| Orchestrator     | [Ansible]                            | Idempotent install, config, and dotfile deployment |
| Runtimes         | [Mise]                               | Node, Python, Rust version management              |
| Package managers | Homebrew / apt+snap+flatpak / WinGet | Platform-native package installation               |

Ansible runs locally on macOS and Ubuntu (`connection: local`). On Windows, it runs from WSL2 and connects to the Windows host over WinRM using the WSL2 gateway address.

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
│   │   ├── group_vars/all.yml   # Cross-platform vars (git config, cargo/pip packages)
│   │   ├── localhost.yml        # macOS / Ubuntu target
│   │   └── windows.yml         # Windows target (WinRM via WSL2 gateway)
│   ├── playbooks/
│   │   ├── install.yml          # Main install playbook (runs verify at end)
│   │   ├── upgrade.yml          # Upgrade all packages
│   │   └── verify.yml           # Verify tools are installed
│   ├── requirements.yml         # Ansible Galaxy collections
│   └── roles/
│       ├── bootstrap/           # Package manager setup (Homebrew, apt repos, WinGet)
│       ├── runtimes/            # Node, Python, Rust via Mise
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
├── .bashrc                      # Bash config (Ubuntu)
├── .mise.toml                   # Runtime version pins (Node, Python, Rust)
└── Justfile                     # Convenience wrappers around ansible-playbook
```

## What Gets Installed

`all` means macOS, Ubuntu, and Windows.

### Runtimes

| Runtime      | Platforms | Manager                                                             |
| ------------ | --------- | ------------------------------------------------------------------- |
| [Node.js]    | all       | Mise (macOS/Ubuntu), WinGet (Windows)                               |
| [Python]     | all       | Mise (macOS/Ubuntu), WinGet (Windows)                               |
| [Rust]       | all       | Mise (macOS/Ubuntu), WinGet/rustup (Windows)                        |
| [.NET]       | Windows   | WinGet                                                              |
| [Docker]     | all       | OrbStack (macOS), apt (Ubuntu), Docker Desktop via WinGet (Windows) |
| [PowerShell] | all       | Homebrew (macOS), apt (Ubuntu), WinGet (Windows)                    |

### Tools

| Tool             | Platforms       | Description                            |
| ---------------- | --------------- | -------------------------------------- |
| [bat]            | all             | `cat` clone with syntax highlighting   |
| [bottom]         | Ubuntu, Windows | Terminal system monitor                |
| [eza]            | all             | Modern `ls` replacement                |
| [fzf]            | all             | Command-line fuzzy finder              |
| [Git LFS]        | all             | Git Large File Storage                 |
| [jq]             | all             | `sed` for JSON                         |
| [just]           | all             | Task runner                            |
| [less]           | macOS, Windows  | Terminal pager                         |
| [pandoc]         | all             | Universal markup converter             |
| [pnpm]           | all             | Fast JavaScript package manager        |
| [ripgrep]        | all             | Fast regex search                      |
| [ripgrep-all]    | macOS, Ubuntu   | ripgrep across PDFs, Office docs, etc. |
| [shellcheck]     | macOS, Ubuntu   | Shell script linter                    |
| [Starship]       | all             | Cross-shell prompt                     |
| [UPX]            | all             | Executable packer                      |
| [NuGet]          | Windows         | .NET package manager                   |
| [PuTTY]          | Windows         | SSH client                             |
| [VS Build Tools] | Windows         | MSVC compiler toolchain                |
| [Docker] (apt)   | Ubuntu          | Container runtime                      |
| [Flatpak]        | Ubuntu          | Application distribution               |
| [ffmpeg]         | Ubuntu          | Media processing                       |

### Apps

| App           | Platforms       | Description                                           |
| ------------- | --------------- | ----------------------------------------------------- |
| [VS Code]     | all             | Code editor                                           |
| [draw.io]     | all             | Diagramming                                           |
| [Obsidian]    | all             | Note-taking                                           |
| [Spotify]     | Ubuntu, Windows | Music                                                 |
| [Telegram]    | macOS, Windows  | Messaging                                             |
| [OrbStack]    | macOS           | Container and VM runtime (Docker Desktop replacement) |
| [Raindrop.io] | macOS           | Bookmark manager                                      |
| [7-Zip]       | Windows         | File archiver                                         |
| [Caesium]     | Windows         | Image compressor                                      |
| [DBeaver]     | Windows         | Universal database tool                               |
| [Amberol]     | Ubuntu          | Music player                                          |
| [Brave]       | Ubuntu          | Web browser                                           |

### Cross-Platform Packages

Installed on all platforms via their respective package managers:

| Type    | Packages                                                                           |
| ------- | ---------------------------------------------------------------------------------- |
| Cargo   | `cargo-modules`, `cargo-outdated`, `cargo-update`, `diskonaut`, `wasm-pack`        |
| pip     | `ansible-core`, `ansible-lint`, `checkov`, `ipykernel`, `pre-commit`, `setuptools` |
| pnpm    | `cspell`                                                                           |
| VS Code | GitLens, EditorConfig, Markdownlint, Night Owl theme, VS Code Icons                |

### Scripts

Deployed to `~/.local/bin` on macOS and Ubuntu:

| Command     | Description                                                  |
| ----------- | ------------------------------------------------------------ |
| `ff <term>` | Fuzzy find files matching a search term, previewed with bat  |
| `ll [path]` | List files with eza (long format, git-aware, human-readable) |

## Documentation

- [docs/principles.md](docs/principles.md) — Architecture principles guiding tool and approach choices
- [docs/adr/](docs/adr/) — Architecture Decision Records

## Testing

Test the code in this repo with:

```sh
just pre-commit
just ansible-lint
just spellcheck
```

[Ansible]: https://www.ansible.com/
[Mise]: https://mise.jdx.dev/
[.NET]: https://dotnet.microsoft.com/
[7-Zip]: https://7-zip.org/
[Amberol]: https://gitlab.gnome.org/World/amberol
[bat]: https://github.com/sharkdp/bat
[bottom]: https://clementtsang.github.io/bottom/
[Brave]: https://brave.com/
[Caesium]: https://saerasoft.com/caesium
[DBeaver]: https://dbeaver.io/
[Docker]: https://www.docker.com/
[draw.io]: https://www.drawio.com/
[eza]: https://github.com/eza-community/eza
[ffmpeg]: https://ffmpeg.org/
[Flatpak]: https://flatpak.org/
[fzf]: https://github.com/junegunn/fzf
[Git LFS]: https://git-lfs.com/
[jq]: https://jqlang.github.io/jq/
[just]: https://just.systems/
[less]: https://www.greenwoodsoftware.com/less/
[Node.js]: https://nodejs.org/
[NuGet]: https://www.nuget.org/
[Obsidian]: https://obsidian.md/
[OrbStack]: https://orbstack.dev/
[pandoc]: https://pandoc.org/
[pnpm]: https://pnpm.io/
[PowerShell]: https://github.com/PowerShell/PowerShell
[PuTTY]: https://putty.org/
[Python]: https://www.python.org/
[Raindrop.io]: https://raindrop.io/
[ripgrep]: https://github.com/BurntSushi/ripgrep
[ripgrep-all]: https://github.com/phiresky/ripgrep-all
[Rust]: https://www.rust-lang.org/
[shellcheck]: https://www.shellcheck.net/
[Spotify]: https://open.spotify.com/
[Starship]: https://starship.rs/
[Telegram]: https://telegram.org/
[UPX]: https://upx.github.io/
[VS Build Tools]: https://visualstudio.microsoft.com/visual-cpp-build-tools/
[VS Code]: https://code.visualstudio.com/
