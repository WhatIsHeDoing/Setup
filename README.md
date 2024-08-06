# 💻 Prep My OS

## 👋 Introduction

This repository contains a group of scripts that set up my common environments.

These can be re-run at any time, and will update pre-installed packages, runtimes and their associated packages, plus global configuration.
Each script is designed to set up each Operating System (OS) using similar tools where possible,
such as [Starship] as the shell prompt and [VS Code] as the code editor,
to simplify moving between them.

Click on the [Ubuntu] version below to see it in action:

[![asciicast](https://asciinema.org/a/kblRtgZYt1p78qMtcgQ8UNAMi.svg)](https://asciinema.org/a/kblRtgZYt1p78qMtcgQ8UNAMi)

## 🏃‍ Running

Run one of the following for your OS in your terminal of choice:

```sh
sh setup_debian.sh
sh setup_fedora.sh
sh setup_ubuntu.sh
.\setup_windows.ps1
```

## 🔋 Included

As current support for Debian and Fedora is currently limited, `all` platforms means Ubuntu and Windows.

### 👟 Runtimes

| Runtime      | Platforms | Description                                                           |
| ------------ | --------- | --------------------------------------------------------------------- |
| [.NET]       | all       | Free, open-source, cross-platform framework                           |
| [Docker]     | all       | Containerize applications                                             |
| [gcc]        | all       | GNU Compiler Collection                                               |
| [kubectl]    | all       | kubectl controls the Kubernetes cluster manager                       |
| [minikube]   | all       | Fast Kubernetes cluster set up                                        |
| [Node.js]    | all       | Free, open-source, cross-platform JavaScript runtime environment      |
| [Powershell] | all       | Automation and configuration tool/framework                           |
| [Python]     | all       | Programming language                                                  |
| [Rust]       | all       | Language empowering everyone to build reliable and efficient software |

### 🔨 Tools

| Tool              | Platforms | Description                                                               |
| ----------------- | --------- | ------------------------------------------------------------------------- |
| [7zip]            | all       | File archiver with a high compression ratio                               |
| [Amberol]         | Ubuntu    | A small and simple sound and music player                                 |
| [asciinema]       | Ubuntu    | Record and share terminal sessions                                        |
| [bat]             | all       | A `cat(1)` clone with wings                                               |
| [bottom]          | all       | Terminal graphical process/system monitor                                 |
| [Caesium]         | Windows   | Image compressor                                                          |
| [cargo-outdated]  | all       | cargo subcommand to show outdated Rust dependencies                       |
| [DBeaver]         | all       | Universal database tool                                                   |
| [diskonaut]       | all       | Terminal disk space navigator                                             |
| [draw.io]         | all       | Technology stack for building diagramming applications                    |
| [eza]             | all       | Modern, maintained replacement for `ls`                                   |
| [Flatpak]         | all       | The future of apps on Linux                                               |
| [fzf]             | all       | Command-line fuzzy finder                                                 |
| [Git]             | all       | Distributed version control system                                        |
| [Helm]            | all       | Package manager for Kubernetes                                            |
| [innounp]         | Windows   | Inno Setup unpacker                                                       |
| [IPython]         | all       | Toolkit to run Python interactively, including Jupyter                    |
| [jid]             | all       | JSON incremental digger                                                   |
| [jq]              | all       | `sed` for JSON data                                                       |
| [just]            | all       | Just a command runner                                                     |
| [k9s]             | Windows   | Kubernetes CLI to manage your clusters in style!                          |
| [less]            | all       | Terminal pager                                                            |
| [nuget]           | Windows   | Package manager for .NET                                                  |
| [pandoc]          | all       | Universal markup converter                                                |
| [pnpm]            | all       | Fast, disk space efficient JavaScript package manager                     |
| [Portmaster]      | Windows   | App firewall and monitor                                                  |
| [powersession-rs] | Windows   | A Rust port of `asciinema` for Windows                                    |
| [pre-commit]      | all       | A framework for managing and maintaining multi-language pre-commit hooks  |
| [Pulumi]          | all       | Create, deploy, and manage infrastructure on any cloud using any language |
| [PuTTY]           | Windows   | SSH and telnet client                                                     |
| [RapidEE]         | Windows   | Rapid Environment Editor                                                  |
| [rga]             | all       | Regex-based search tool for a multitude of file types                     |
| [Scoop]           | Windows   | Command-line installer for Windows                                        |
| [SpaceSniffer]    | Windows   | Visualise folder and file structures on disk                              |
| [Spotify]         | all       | Digital music service                                                     |
| [Starship]        | all       | Cross-shell prompt                                                        |
| [Telegram]        | all       | Messaging                                                                 |
| [UPX]             | all       | Executable packer                                                         |
| [VS Code]         | all       | Code editor                                                               |
| [Warp]            | Ubuntu    | The terminal reimagined                                                   |
| [WSL]             | Windows   | Run a GNU/Linux environment directly on Windows                           |
| [Zed]             | Ubuntu    | Zed is a high-performance, multiplayer code editor                        |

### 🦀 Rust Modules

| Runtime          | Description                                                                   |
| ---------------- | ----------------------------------------------------------------------------- |
| [cargo-outdated] | A cargo subcommand for checking and applying updates to installed executables |
| [cargo-modules]  | A cargo plugin for showing a tree-like overview of a crate's modules          |
| [cargo-update]   | A cargo subcommand for checking and applying updates to installed executables |
| [wasm-pack]      | 📦✨ your favourite rust -> wasm workflow tool!                                 |

### ⚙️ Scripts

Some tools require extra configuration or combinations to get the best from them.
The scripts below are available as aliases on Ubuntu and Windows:

| Global Alias | Meaning      | Description                                                            |
| ------------ | ------------ | ---------------------------------------------------------------------- |
| `ll`         | long listing | Comprehensive listing of files in the current directory                |
| `ff <term>`  | fuzzy find   | Fuzzy find of a search term for all files within the current directory |

## 🧪 Testing

First, set up [pre-commit] and run an initial test:

```sh
pre-commit install
pre-commit run --all-files
```

The majority of the Ubuntu setup script can be tested on any platform using a [Docker] container. Build and run it with:

```sh
docker build --progress=plain -f Dockerfile.ubuntu -t setup_ubuntu .
docker run -it setup_ubuntu
```

Similarly, the _entire_ Fedora script can be tested in Docker with:

```sh
docker build --progress=plain -f Dockerfile.fedora -t setup_fedora .
docker run -it setup_fedora
```

Containers should be verified with [Container Structure Tests], vulnerabilities with [Grype] and best practices with [Kics]:

```sh
grype setup_ubuntu
docker run -t -v /home/user/Setup:/Dockerfile checkmarx/kics:latest scan -p .
container-structure-test test --image setup_ubuntu --config container-structure-test.yml
```

## 💡 Inspiration

The initial inspiration came from a post by [Scott Hanselman] on how to make a pretty prompt in Windows Terminal.

[.NET]: https://dotnet.microsoft.com/
[7zip]: https://7-zip.org/
[Amberol]: https://gitlab.gnome.org/World/amberol
[asciinema]: https://asciinema.org/
[bat]: https://github.com/sharkdp/bat
[bottom]: https://clementtsang.github.io/bottom/
[Caesium]: https://saerasoft.com/caesium
[cargo-outdated]: https://github.com/kbknapp/cargo-outdated
[cargo-modules]: https://crates.io/crates/cargo-modules
[cargo-update]: https://crates.io/crates/cargo-update
[Container Structure Tests]: https://github.com/GoogleContainerTools/container-structure-test
[DBeaver]: https://dbeaver.io/
[diskonaut]: https://github.com/imsnif/diskonaut
[Docker]: https://www.docker.com/
[draw.io]: https://www.drawio.com/
[eza]: https://github.com/eza-community/eza
[Flatpak]: https://flatpak.org/
[fzf]: https://github.com/junegunn/fzf
[gcc]: https://gcc.gnu.org/
[Git]: https://git-scm.com/
[Grype]: https://github.com/anchore/grype
[Helm]: https://helm.sh/
[innounp]: https://innounp.sourceforge.net/
[IPython]: https://ipython.readthedocs.io/
[jid]: https://github.com/simeji/jid
[jq]: https://jqlang.github.io/jq/
[just]: https://just.systems/
[k9s]: https://k9scli.io/
[Kics]: https://kics.io/
[kubectl]: https://kubernetes.io/docs/reference/kubectl/kubectl/
[less]: https://www.greenwoodsoftware.com/less/
[minikube]: https://minikube.sigs.k8s.io/
[Node.js]: https://nodejs.org/
[nuget]: https://www.nuget.org/
[pandoc]: https://pandoc.org/
[pnpm]: https://pnpm.io/
[Portmaster]: https://safing.io/
[powersession-rs]: https://github.com/Watfaq/PowerSession-rs
[Powershell]: https://github.com/PowerShell/PowerShell
[pre-commit]: https://pre-commit.com/
[Pulumi]: https://www.pulumi.com/
[PuTTY]: https://putty.org/
[Python]: https://www.python.org/
[RapidEE]: https://www.rapidee.com/
[rga]: https://github.com/phiresky/ripgrep-all
[Rust]: https://www.rust-lang.org/
[Scoop]: https://scoop.sh/
[Scott Hanselman]: https://www.hanselman.com/blog/HowToMakeAPrettyPromptInWindowsTerminalWithPowerlineNerdFontsCascadiaCodeWSLAndOhmyposh.aspx
[SpaceSniffer]: http://www.uderzo.it/main_products/space_sniffer/
[Spotify]: https://open.spotify.com/
[Starship]: https://starship.rs/
[Telegram]: https://telegram.org/
[Ubuntu]: https://ubuntu.com/
[UPX]: https://upx.github.io/
[VS Code]: https://code.visualstudio.com/
[Warp]: https://www.warp.dev/
[wasm-pack]: https://rustwasm.github.io/wasm-pack/
[WSL]: https://learn.microsoft.com/en-us/windows/wsl/
[Zed]: https://zed.dev/
