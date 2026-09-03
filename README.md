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
│   │   ├── upgrade.yml          # Upgrade all packages, then prune caches
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
│   ├── bootstrap_ubuntu.sh      # Installs Ansible, just
│   └── bootstrap_windows.ps1   # Installs Git, configures WinRM, sets up WSL2
├── config/
│   ├── zsh/                     # Zsh fragments, sourced from ~/.config/zsh
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
| [actionlint]              | macOS, Windows | Static checker for GitHub Actions workflows       |
| [asciinema]               | macOS, Ubuntu  | Record and share terminal sessions                |
| [atuin]                   | macOS, Ubuntu  | Shell history with sync and interactive search    |
| [bash]                    | macOS          | GNU Bash 5.x, replacing the bundled Bash 3.2      |
| [bat]                     | all            | `cat` clone with syntax highlighting              |
| [bats-assert]             | macOS          | Common assertions for Bats                        |
| [bats-core]               | macOS, Ubuntu  | Bash Automated Testing System                     |
| [bats-support]            | macOS          | Supporting library for Bats test helpers          |
| [bottom]                  | all            | Terminal system monitor                           |
| [clang-format]            | macOS, Ubuntu  | Formatter for C, C++, Obj-C and Java              |
| [coreutils]               | macOS          | GNU file and text utilities, `g`-prefixed         |
| [cppcheck]                | all            | Static analysis for C and C++                     |
| [cspell]                  | macOS, Ubuntu  | Spell checker for code and prose                  |
| [delta]                   | all            | Syntax-highlighted diffs; configured as git pager |
| [diffutils]               | macOS          | GNU `diff`, `cmp`, `diff3` — take the plain names |
| [dust]                    | macOS          | Intuitive disk usage viewer                       |
| [duti]                    | macOS          | Set default file-type handler associations        |
| [exiftool]                | all            | Read and write image and media metadata           |
| [eza]                     | all            | Modern `ls` replacement                           |
| [fd]                      | all            | Fast and user-friendly `find` alternative         |
| [findutils]               | macOS          | GNU `find` and `xargs` as `gfind` and `gxargs`    |
| [fzf]                     | all            | Command-line fuzzy finder                         |
| [gawk]                    | macOS          | GNU Awk, installed as `gawk`                      |
| [gh]                      | all            | GitHub CLI                                        |
| [ghostscript]             | all            | Interpreter for PostScript and PDF                |
| [git]                     | macOS          | Version control, newer than the Apple build       |
| [Git LFS]                 | all            | Git Large File Storage                            |
| [git-filter-repo]         | macOS, Ubuntu  | Quickly rewrite git repository history            |
| [gitleaks]                | all            | Secret scanner for git repositories               |
| [gnu-sed]                 | macOS          | GNU sed, installed as `gsed`                      |
| [graphviz]                | all            | Graph visualization via the DOT language          |
| [grep]                    | macOS          | GNU grep, installed as `ggrep`                    |
| [hyperfine]               | all            | Command-line benchmarking tool                    |
| [ImageMagick]             | all            | Create, edit and convert bitmap images            |
| [jq]                      | all            | `sed` for JSON                                    |
| [JupyterLab]              | macOS, Ubuntu  | Notebook IDE; brings the IPython kernel with it   |
| [just]                    | all            | Task runner                                       |
| [lazygit]                 | all            | TUI for git                                       |
| [lefthook]                | all            | Fast, polyglot git hooks manager                  |
| [less]                    | all            | Terminal pager                                    |
| [lychee]                  | macOS, Windows | Fast link checker for Markdown, HTML, and code    |
| [make]                    | macOS          | GNU Make 4.x, installed as `gmake`                |
| [markdownlint-cli2]       | macOS          | Markdown linter and formatter                     |
| [miller]                  | all            | Swiss Army knife for tabular data (CSV/JSON/TSV)  |
| [ollama]                  | macOS, Windows | Run large language models locally                 |
| [pandoc]                  | all            | Universal markup converter                        |
| [pinact]                  | macOS          | Pin GitHub Actions to full-length hashes          |
| [pnpm]                    | all            | Fast JavaScript package manager                   |
| [poppler]                 | macOS, Ubuntu  | PDF rendering library and CLI utilities           |
| [promptfoo]               | macOS, Ubuntu  | Test and evaluate LLM apps locally                |
| [ripgrep]                 | all            | Fast regex search                                 |
| [ripgrep-all]             | all            | ripgrep across PDFs, Office docs, etc.            |
| [rsync]                   | macOS          | GNU rsync, replacing the bundled openrsync        |
| [rtk]                     | macOS          | CLI proxy that cuts LLM token use                 |
| [sd]                      | all            | Find and replace, same syntax on every platform   |
| [shellcheck]              | all            | Shell script linter                               |
| [shfmt]                   | all            | Shell script formatter                            |
| [sqlfluff]                | macOS, Ubuntu  | SQL linter and auto-formatter                     |
| [Starship]                | all            | Cross-shell prompt                                |
| [stylelint]               | macOS, Ubuntu  | Modern CSS linter                                 |
| [svgo]                    | macOS          | SVG optimizer                                     |
| [taplo]                   | macOS, Ubuntu  | TOML toolkit (format and lint)                    |
| [tlrc]                    | macOS          | Community tldr pages client                       |
| [tokei]                   | all            | Count code quickly, by language                   |
| [UPX]                     | all            | Executable packer                                 |
| [vale]                    | macOS, Windows | Prose linter for docs and Markdown                |
| [wabt]                    | macOS, Ubuntu  | WebAssembly binary toolkit                        |
| [websocat]                | macOS, Ubuntu  | Command-line client for WebSockets                |
| [yamllint]                | macOS, Ubuntu  | Linter for YAML files                             |
| [yq]                      | all            | YAML/JSON/XML processor (jq for YAML)             |
| [zizmor]                  | macOS, Ubuntu  | Find security issues in GitHub Actions            |
| [zoxide]                  | all            | Smarter `cd` that learns your habits              |
| [Zsh]                     | Ubuntu         | Shell — macOS already ships it, apt installs it   |
| [zsh-autocomplete]        | macOS, Ubuntu  | Real-time tab completion for Zsh                  |
| [zsh-autosuggestions]     | macOS, Ubuntu  | Fish-style history suggestions for Zsh            |
| [zsh-syntax-highlighting] | macOS, Ubuntu  | Fish-style syntax highlighting for Zsh            |
| [NuGet]                   | all            | .NET package manager                              |
| [PuTTY]                   | Windows        | SSH client                                        |
| [VS Build Tools]          | Windows        | MSVC compiler toolchain                           |
| [Docker] (apt)            | Ubuntu         | Container runtime                                 |
| [Flatpak]                 | Ubuntu         | Application distribution                          |
| [ffmpeg]                  | all            | Media processing                                  |

### Apps

| App                        | Platforms       | Description                                           |
| -------------------------- | --------------- | ----------------------------------------------------- |
| [7-Zip]                    | Windows         | File archiver                                         |
| [AlDente]                  | macOS           | Battery charge limiter                                |
| [Amberol]                  | Ubuntu          | Music player                                          |
| [Bambu Studio]             | macOS           | Slicer for Bambu Lab 3D printers                      |
| [Caesium]                  | Ubuntu, Windows | Image compressor                                      |
| [Claude]                   | macOS, Windows  | Claude desktop app                                    |
| [Claude Code]              | macOS           | AI coding assistant CLI                               |
| [DBeaver]                  | all             | Universal database tool                               |
| [draw.io]                  | all             | Diagramming                                           |
| [Firefox]                  | all             | Web browser                                           |
| [ghostty]                  | macOS, Ubuntu   | Fast, native terminal emulator                        |
| [Google Chrome]            | macOS           | Web browser                                           |
| [Ice]                      | macOS           | Menu bar manager                                      |
| [JetBrains Mono Nerd Font] | macOS           | Nerd Font for terminal icons (Starship, eza, etc.)    |
| [Linear]                   | macOS           | Issue tracking and project planning                   |
| [Microsoft Edge]           | macOS           | Web browser                                           |
| [Microsoft Teams]          | macOS           | Video calls and team chat                             |
| [Miro]                     | macOS           | Collaborative whiteboard                              |
| [Notion]                   | macOS           | Notes, documents and databases                        |
| [Obsidian]                 | all             | Note-taking                                           |
| [OrbStack]                 | macOS           | Container and VM runtime (Docker Desktop replacement) |
| [Raindrop.io]              | macOS, Windows  | Bookmark manager                                      |
| [Raycast]                  | macOS           | Launcher, window manager, clipboard history           |
| [Spotify]                  | all             | Music                                                 |
| [Surfshark]                | macOS           | VPN client                                            |
| [Telegram]                 | all             | Messaging                                             |
| [VS Code]                  | all             | Code editor                                           |
| [WhatsApp]                 | macOS           | Messaging                                             |

### Runtime-Manager Packages

What cargo, uv and pnpm install, for the platforms where no OS package
manager carries the package at upstream parity. An OS manager wins whenever
it does — which is why several rows read Ubuntu rather than all, macOS taking
those from Homebrew and Windows from WinGet or going without. See
[ADR-0010](docs/adr/0010-os-package-managers-before-runtime-ones.md).

Windows runs its own runtime tasks over the cross-platform lists alone, so an
Ubuntu row means Ubuntu alone even where the variable name says `non_darwin`.

| Manager | Platforms | Packages                                                                                                                      |
| ------- | --------- | ----------------------------------------------------------------------------------------------------------------------------- |
| Cargo   | all       | `cargo-modules`                                                                                                               |
| Cargo   | Ubuntu    | `cargo-cache`, `cargo-outdated`, `cargo-update`, `diskonaut`, `ripgrep_all`, `sd`, `tokei`, `wasm-pack`, `websocat`, `zizmor` |
| uv      | all       | `ansible-core`, `ansible-lint`, `checkov`, `commitizen`                                                                       |
| uv      | Ubuntu    | `jupyterlab`, `sqlfluff`, `yamllint`                                                                                          |
| pnpm    | Ubuntu    | `cspell`, `promptfoo`, `stylelint`                                                                                            |
| VS Code | all       | GitLens, EditorConfig, Markdownlint, Night Owl theme, VS Code Icons                                                           |

### Omitted Tools

Tools considered and left out, recorded so the decision does not get made twice.
Several are installed by hand on one machine — `just diff` goes on reporting
those, which is the intent: undeclared is a prompt to review, not a fault.

**[carapace]** — a multi-shell completer covering some 650 commands. Rejected on
three counts. Its `aws` completer only wraps `aws_completer`, the binary the AWS
CLI already ships, so it does not solve the problem it was considered for. It
registers a single `compdef` across every command it knows, which on this
machine would replace 26 completions that ship with the tool they complete and
track its version — `git`, `gh`, `brew`, `kubectl` and `just` among them — as
well as zsh's own for `ls`, `cp`, `grep` and `ssh`. And its generated init
prepends its own directory to `PATH`, landing ahead of every entry
[`00-path.zsh`](config/zsh/00-path.zsh) places deliberately — the user-installs
-first ordering [ADR-0007] relies on. It is also absent from apt, so Ubuntu would need a bespoke
download. Startup cost was not the problem: it measured ~10 ms against an 800 ms
shell start. AWS completion instead comes from `aws_completer`, wired in
[`50-tools.zsh`](config/zsh/50-tools.zsh).

**[bun]** — a second JavaScript runtime beside the nvm-managed Node that
[ADR-0006] makes authoritative. Installed by hand; declaring it would put two
runtimes on every machine to serve one.

**Kubernetes tooling** ([k9s], [kubernetes-cli], [tilt]) — used on one machine
for one project rather than across the fleet, so it does not earn a place in a
cross-platform baseline.

**Swift and Xcode tooling** ([SwiftLint], [swift-format], [XcodeGen],
[xcbeautify], [Periphery]) — macOS-only by nature, and tied to specific projects
rather than the machine.

**Occasional utilities** ([Turso], [figlet], [caesiumclt], [vorbis-tools],
[cpanminus]) — installed for a single task each. A rebuild does not need them,
and the ones that matter are quicker to reinstall than to maintain here.

### Scripts

Deployed to `~/.local/bin` on macOS and Ubuntu:

| Command     | Description                                                  |
| ----------- | ------------------------------------------------------------ |
| `ff <term>` | Fuzzy find files matching a search term, previewed with bat  |
| `ll [path]` | List files with eza (long format, git-aware, human-readable) |

## Shell configuration (macOS and Ubuntu)

Zsh config lives in [config/zsh/](config/zsh/) as ordinary `.zsh` files. The
`dotfiles` role deploys them to `~/.config/zsh/` and adds a single source hook
to `~/.zprofile` and `~/.zshrc` — see
[ADR-0008](docs/adr/0008-shell-config-as-repo-owned-fragments.md). Edit the
files in the repo; the deployed copies are overwritten on every run.

Both platforms get the same eight files. Nothing is templated or split per
platform: each fragment detects what the machine actually has — a Homebrew
prefix or not, plugins under `/usr/share` or `~/.local/share` — so the
difference between macOS and Ubuntu stays inside the shell code, where `zsh -n`
can check it. See
[ADR-0009](docs/adr/0009-shell-fragments-detect-rather-than-branch.md). macOS
already runs zsh; on Ubuntu the `os_config` role sets it as the login shell,
which takes effect at the next login.

| Fragment              | Holds                                                     |
| --------------------- | --------------------------------------------------------- |
| `00-path.zsh`         | Homebrew prefix detection and PATH ordering               |
| `10-history.zsh`      | History size, file, and `HIST_*` options                  |
| `20-options.zsh`      | `AUTO_CD`, `CORRECT`, `NO_BEEP`                           |
| `30-env.zsh`          | `NVM_DIR`, `FZF_*`, `RIPGREP_CONFIG_PATH`                 |
| `40-aliases.zsh`      | Aliases                                                   |
| `45-autocomplete.zsh` | zsh-autocomplete — must precede anything that binds a key |
| `50-tools.zsh`        | nvm, starship, zoxide, fzf, atuin initialisation          |
| `90-plugins.zsh`      | zsh-autosuggestions, zsh-syntax-highlighting              |
| `99-local.zsh`        | Machine-specific overrides — seeded once, never touched   |

The numeric prefixes set load order, and three orderings are load-bearing.
zsh-autocomplete loads at 45, ahead of the tools: its initialisation points the
`main` keymap at a fresh `emacs` one, discarding any binding already applied
there, so loading it later costs atuin its Ctrl-R. fzf then initialises before
atuin, so atuin wins that binding rather than fzf. zsh-syntax-highlighting
sorts last, because it has to wrap every widget bound before it.

`verify.yml` asserts all three bindings after assembling the shell, so losing
one fails the run instead of going unnoticed until you next reach for it.

Put anything personal to one machine — agent sockets, credentials, per-host
paths — in `~/.config/zsh/99-local.zsh`. The role seeds it from
`config/zsh/99-local.zsh.example` once and never overwrites it, and it sorts
last so it can override any repo-managed fragment.

### PATH ordering

`00-path.zsh` fixes the search order. Without it, Homebrew loses to Apple's
copies of `jq`, `less`, `bash` and the rest — see
[ADR-0007](docs/adr/0007-prefer-faster-updating-tool-sources.md) for why. Ubuntu
has nothing to correct, and the same file runs there to put user installs ahead
of what apt puts in `/usr/bin`.

The resulting order on macOS is:

| Position | Entry                       | Holds                                                     |
| -------- | --------------------------- | --------------------------------------------------------- |
| 1        | `~/.local/bin`              | uv-installed Python tools, `ff` and `ll`                  |
| 2        | `~/.cargo/bin`              | cargo-installed binaries                                  |
| 3–4      | pnpm's global bin           | `~/Library/pnpm` on macOS, `~/.local/share/pnpm` on Linux |
| 5        | `~/.dotnet/tools`           | .NET global tools                                         |
| 6–7      | Homebrew `bin` and `sbin`   | everything in the Tools and Apps tables — macOS only      |
| 8+       | `/usr/bin`, `/bin`, `/sbin` | what the OS ships                                         |

GNU replacements install under `g`-prefixed names — `gsed`, `ggrep`, `gfind`,
`gmake`, `gawk`, and the coreutils set (`gdate`, `gcp`, `gls`, …). Their
`libexec/gnubin` directories stay **off** PATH on purpose, so a plain `sed` or
`find` keeps BSD semantics and no existing script changes behaviour. Reach for
the `g`-prefixed name when you specifically want GNU.

Three formulae are the exception and take the plain name, replacing Apple's
copy outright: `bash`, `rsync`, and `diffutils` (`diff`, `cmp`, `diff3`). None
of this applies to Ubuntu, where apt already ships the GNU originals unprefixed.

`ansible/playbooks/verify.yml` asserts the ordering by resolving each override
in a login shell, so a regression fails the run rather than going unnoticed.

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

### Emoji skin tone (macOS)

macOS ships no global skin-tone setting — its emoji picker learns a tone one
emoji at a time, as you pick them. The `os_config` role seeds that choice for all
323 emoji that accept a modifier, so a fresh machine offers the tone you want
straight away. Change it in `ansible/inventory/group_vars/all.yml`:

```yaml
macos_emoji_skin_tone: light # light, medium-light, medium, medium-dark or dark
```

Set it to `""` to leave the picker alone. Log out and back in after a change —
the picker reads these defaults when it starts. Emoji taking two tones at once,
such as 🤝 and couples, still need picking by hand.

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
[actionlint]: https://rhysd.github.io/actionlint/
[ADR-0006]: docs/adr/0006-tech-specific-runtime-managers.md
[ADR-0007]: docs/adr/0007-prefer-faster-updating-tool-sources.md
[AlDente]: https://apphousekitchen.com/
[Amberol]: https://gitlab.gnome.org/World/amberol
[Ansible]: https://www.ansible.com/
[asciinema]: https://asciinema.org/
[atuin]: https://atuin.sh/
[Bambu Studio]: https://bambulab.com/en/download/studio
[bash]: https://www.gnu.org/software/bash/
[bat]: https://github.com/sharkdp/bat
[bats-assert]: https://github.com/bats-core/bats-assert
[bats-core]: https://github.com/bats-core/bats-core
[bats-support]: https://github.com/bats-core/bats-support
[bottom]: https://clementtsang.github.io/bottom/
[bun]: https://bun.sh/
[Caesium]: https://saerasoft.com/caesium
[caesiumclt]: https://github.com/Lymphatus/caesium-clt
[carapace]: https://carapace.sh/
[clang-format]: https://clang.llvm.org/docs/ClangFormat.html
[Claude]: https://claude.com/download
[Claude Code]: https://claude.ai/code
[coreutils]: https://www.gnu.org/software/coreutils/
[cpanminus]: https://github.com/miyagawa/cpanminus
[cppcheck]: https://cppcheck.sourceforge.io/
[cspell]: https://cspell.org/
[DBeaver]: https://dbeaver.io/
[delta]: https://dandavison.github.io/delta/
[diffutils]: https://www.gnu.org/software/diffutils/
[Docker]: https://www.docker.com/
[draw.io]: https://www.drawio.com/
[dust]: https://github.com/bootandy/dust
[duti]: https://github.com/moretension/duti
[exiftool]: https://exiftool.org/
[eza]: https://github.com/eza-community/eza
[fd]: https://github.com/sharkdp/fd
[ffmpeg]: https://ffmpeg.org/
[figlet]: http://www.figlet.org/
[findutils]: https://www.gnu.org/software/findutils/
[Firefox]: https://www.mozilla.org/firefox/
[Flatpak]: https://flatpak.org/
[fzf]: https://github.com/junegunn/fzf
[gawk]: https://www.gnu.org/software/gawk/
[gh]: https://cli.github.com/
[ghostscript]: https://www.ghostscript.com/
[ghostty]: https://ghostty.org/
[git]: https://git-scm.com/
[Git LFS]: https://git-lfs.com/
[git-filter-repo]: https://github.com/newren/git-filter-repo
[gitleaks]: https://github.com/gitleaks/gitleaks
[gnu-sed]: https://www.gnu.org/software/sed/
[Google Chrome]: https://www.google.com/chrome/
[graphviz]: https://graphviz.org/
[grep]: https://www.gnu.org/software/grep/
[hyperfine]: https://github.com/sharkdp/hyperfine
[Ice]: https://github.com/jordanbaird/Ice
[ImageMagick]: https://imagemagick.org/
[JetBrains Mono Nerd Font]: https://www.nerdfonts.com/
[jq]: https://jqlang.github.io/jq/
[JupyterLab]: https://jupyter.org/
[just]: https://just.systems/
[k9s]: https://k9scli.io/
[kubernetes-cli]: https://kubernetes.io/docs/reference/kubectl/
[lazygit]: https://github.com/jesseduffield/lazygit
[lefthook]: https://lefthook.dev/
[less]: https://www.greenwoodsoftware.com/less/
[Linear]: https://linear.app/
[lychee]: https://lychee.cli.rs/
[make]: https://www.gnu.org/software/make/
[markdownlint-cli2]: https://github.com/DavidAnson/markdownlint-cli2
[Microsoft Edge]: https://www.microsoft.com/edge
[Microsoft Teams]: https://www.microsoft.com/microsoft-teams/group-chat-software/
[miller]: https://miller.readthedocs.io/
[Miro]: https://miro.com/
[Node.js]: https://nodejs.org/
[Notion]: https://www.notion.com/
[NuGet]: https://www.nuget.org/
[nvm]: https://github.com/nvm-sh/nvm
[Obsidian]: https://obsidian.md/
[ollama]: https://ollama.com/
[OrbStack]: https://orbstack.dev/
[pandoc]: https://pandoc.org/
[Periphery]: https://github.com/peripheryapp/periphery
[pinact]: https://github.com/suzuki-shunsuke/pinact
[pnpm]: https://pnpm.io/
[poppler]: https://poppler.freedesktop.org/
[PowerShell]: https://github.com/PowerShell/PowerShell
[promptfoo]: https://promptfoo.dev/
[PuTTY]: https://putty.org/
[Python]: https://www.python.org/
[Raindrop.io]: https://raindrop.io/
[Raycast]: https://www.raycast.com/
[ripgrep]: https://github.com/BurntSushi/ripgrep
[ripgrep-all]: https://github.com/phiresky/ripgrep-all
[rsync]: https://rsync.samba.org/
[rtk]: https://www.rtk-ai.app/
[Rust]: https://www.rust-lang.org/
[rustup]: https://rustup.rs/
[sd]: https://github.com/chmln/sd
[shellcheck]: https://www.shellcheck.net/
[shfmt]: https://github.com/mvdan/sh
[Spotify]: https://open.spotify.com/
[sqlfluff]: https://docs.sqlfluff.com/
[Starship]: https://starship.rs/
[stylelint]: https://stylelint.io/
[Surfshark]: https://surfshark.com/
[svgo]: https://github.com/svg/svgo
[swift-format]: https://github.com/swiftlang/swift-format
[SwiftLint]: https://github.com/realm/SwiftLint
[taplo]: https://taplo.tamasfe.dev/
[Telegram]: https://telegram.org/
[tilt]: https://tilt.dev/
[tlrc]: https://github.com/tldr-pages/tlrc
[tokei]: https://github.com/XAMPPRocky/tokei
[Turso]: https://turso.tech/
[UPX]: https://upx.github.io/
[uv]: https://docs.astral.sh/uv/
[vale]: https://vale.sh/
[vorbis-tools]: https://github.com/xiph/vorbis-tools
[VS Build Tools]: https://visualstudio.microsoft.com/visual-cpp-build-tools/
[VS Code]: https://code.visualstudio.com/
[wabt]: https://github.com/WebAssembly/wabt
[websocat]: https://github.com/vi/websocat
[WhatsApp]: https://www.whatsapp.com/
[xcbeautify]: https://github.com/cpisciotta/xcbeautify
[XcodeGen]: https://github.com/yonaskolb/XcodeGen
[yamllint]: https://yamllint.readthedocs.io/
[yq]: https://github.com/mikefarah/yq
[zizmor]: https://docs.zizmor.sh/
[zoxide]: https://github.com/ajeetdsouza/zoxide
[Zsh]: https://www.zsh.org/
[zsh-autocomplete]: https://github.com/marlonrichert/zsh-autocomplete
[zsh-autosuggestions]: https://github.com/zsh-users/zsh-autosuggestions
[zsh-syntax-highlighting]: https://github.com/zsh-users/zsh-syntax-highlighting
