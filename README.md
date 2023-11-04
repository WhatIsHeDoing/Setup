# Setup

## 👋 Introduction

This repository contains a group of scripts that set up my common environments.

These can be re-run at any time, and will update pre-installed packages, runtimes and their associated packages, plus global configuration.
Each script is designed to set up each Operating System (OS) using similar tools where possible,
such as [Starship] as the shell prompt and [VS Code] as the code editor,
to simplify moving between them.

Click on the [Ubuntu] version below to see it in action:

[![asciicast](https://asciinema.org/a/611447.svg)](https://asciinema.org/a/611447?autoplay=1)

## 🏃‍ Running

Run one of the following for your OS in your terminal of choice:

```sh
sh setup_debian.sh
sh setup_fedora.sh
sh setup_ubuntu.sh
.\setup_windows.ps1
```

## 🧪 Testing

The majority of the Ubuntu setup script can be tested on any platform using a [Docker] container. Build and run it with:

```sh
docker build --progress=plain -f Dockerfile.ubuntu -t setup_ubuntu .
docker run -it setup_ubuntu
```

The container should be verified with [Container Structure Tests], vulnerabilites with [Grype] and best practices with [Kics]:

```sh
grype setup_ubuntu
docker run -t -v /home/user/Setup:/Dockerfile checkmarx/kics:latest scan -p .
container-structure-test test --image setup_ubuntu --config container-structure-test.yml
```

## 💡 Inspiration

- [Scott Hanselman]: How to make a pretty prompt in Windows Terminal with Powerline, Nerd Fonts, Cascadia Code, WSL, and oh-my-posh

[Container Structure Tests]: https://github.com/GoogleContainerTools/container-structure-test
[Docker]: https://www.docker.com/
[Grype]: https://github.com/anchore/grype
[Kics]: https://kics.io/
[Scott Hanselman]: https://www.hanselman.com/blog/HowToMakeAPrettyPromptInWindowsTerminalWithPowerlineNerdFontsCascadiaCodeWSLAndOhmyposh.aspx
[Starship]: https://starship.rs/
[Ubuntu]: https://ubuntu.com/
[VS Code]: https://code.visualstudio.com/
