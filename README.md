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

### 🔨 Tools

As current support for Debian and Fedora is currently limited, `all` platforms means Ubuntu and Windows.

| Tool              | Platforms | Description                                            |
| ----------------- | --------- | ------------------------------------------------------ |
| [7zip]            | all       | File archiver with a high compression ratio            |
| [asciinema]       | Ubuntu    | Record and share terminal sessions                     |
| [bat]             | all       | A `cat(1)` clone with wings.                           |
| [bottom]          | all       | Terminal graphical process/system monitor              |
| [Caesium]         | Windows   | Image compressor                                       |
| [cargo-outdated]  | all       | cargo subcommand to show outdated Rust dependencies    |
| [DBeaver]         | all       | Universal database tool                                |
| [diskonaut]       | all       | Terminal disk space navigator                          |
| [Docker]          | all       | Containerize applications                              |
| [eza]             | all       | Modern, maintained replacement for `ls`                |
| [fzf]             | all       | Command-line fuzzy finder                              |
| [gcc]             | all       | GNU Compiler Collection                                |
| [Git]             | all       | Distributed version control system                     |
| [Helm]            | all       | Package manager for Kubernetes                         |
| [innounp]         | Windows   | Inno Setup unpacker                                    |
| [IPython]         | all       | Toolkit to run Python interactively, including Jupyter |
| [jid]             | all       | JSON incremental digger                                |
| [jq]              | all       | `sed` for JSON data                                    |
| [just]            | all       | Just a command runner                                  |
| [k9s]             | Windows   | Kubernetes CLI to manage your clusters in style!       |
| [kubectl]         | all       | kubectl controls the Kubernetes cluster manager.       |
| [less]            | all       | Terminal pager                                         |
| [minikube]        | all       | Fast Kubernetes  cluster set up                        |
| [Node.js]         | all       | JavaScript runtime environment                         |
| [nuget]           | Windows   | Package manager for .NET                               |
| [pandoc]          | all       | Universal markup converter                             |
| [pnpm]            | all       | Fast, disk space efficient JavaScript package manager  |
| [Portmaster]      | Windows   | App firewall and monitor                               |
| [powersession-rs] | Windows   | A Rust port of `asciinema` for Windows                 |
| [Powershell]      | all       | Automation and configuration tool/framework            |
| [PuTTY]           | Windows   | SSH and telnet client                                  |
| [Python]          | all       | Programming language                                   |
| [RapidEE]         | Windows   | Rapid Environment Editor                               |
| [rga]             | all       | Regex-based search tool for a multitude of file types  |
| [Rust]            | all       | Programming language                                   |
| [Scoop]           | Windows   | Command-line installer for Windows                     |
| [SpaceSniffer]    | Windows   | Visualise folder and file structures on disk           |
| [Spotify]         | all       | Digital music service                                  |
| [Starship]        | all       | Cross-shell prompt                                     |
| [Telegram]        | all       | Messaging                                              |
| [UPX]             | all       | Executable packer                                      |
| [VS Code]         | all       | Code editor                                            |
| [Warp]            | Ubuntu    | The terminal reimagined                                |
| [WSL]             | Windows   | Run a GNU/Linux environment directly on Windows        |

### ⚙️ Scripts

Some tools require extra configuration or combinations to get the best from them.
The scripts below are available as aliases on Ubuntu and Windows:

| Global Alias | Meaning      | Description                                                            |
| ------------ | ------------ | ---------------------------------------------------------------------- |
| `ll`         | long listing | Comprehensive listing of files in the current directory                |
| `ff <term>`  | fuzzy find   | Fuzzy find of a search term for all files within the current directory |

## 🧪 Testing

First, check the shell for problems using [ShellCheck]:

```sh
shellcheck *.sh
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

[7zip]: https://7-zip.org/
[asciinema]: https://asciinema.org/
[bat]: https://github.com/sharkdp/bat
[bottom]: https://clementtsang.github.io/bottom/
[Caesium]: https://saerasoft.com/caesium
[cargo-outdated]: https://github.com/kbknapp/cargo-outdated
[Container Structure Tests]: https://github.com/GoogleContainerTools/container-structure-test
[DBeaver]: https://dbeaver.io/
[diskonaut]: https://github.com/imsnif/diskonaut
[Docker]: https://www.docker.com/
[eza]: https://github.com/eza-community/eza
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
[PuTTY]: https://putty.org/
[Python]: https://www.python.org/
[RapidEE]: https://www.rapidee.com/
[rga]: https://github.com/phiresky/ripgrep-all
[Rust]: https://www.rust-lang.org/
[Scoop]: https://scoop.sh/
[Scott Hanselman]: https://www.hanselman.com/blog/HowToMakeAPrettyPromptInWindowsTerminalWithPowerlineNerdFontsCascadiaCodeWSLAndOhmyposh.aspx
[ShellCheck]: https://www.shellcheck.net/
[SpaceSniffer]: http://www.uderzo.it/main_products/space_sniffer/
[Spotify]: https://open.spotify.com/
[Starship]: https://starship.rs/
[Telegram]: https://telegram.org/
[Ubuntu]: https://ubuntu.com/
[UPX]: https://upx.github.io/
[VS Code]: https://code.visualstudio.com/
[Warp]: https://www.warp.dev/
[WSL]: https://learn.microsoft.com/en-us/windows/wsl/
