# List all available recipes
default:
    @just --list

# Bootstrap prerequisites on this machine (run once on a fresh machine)
bootstrap:
    #!/usr/bin/env sh
    case "$(uname -s)" in
        Darwin) bash bootstrap/bootstrap_macos.sh ;;
        Linux)  bash bootstrap/bootstrap_ubuntu.sh ;;
        *)      echo "On Windows, run: bootstrap\bootstrap_windows.ps1 in PowerShell" ;;
    esac

# Install and configure everything on this machine (macOS / Ubuntu / WSL2)
install:
    ansible-playbook ansible/playbooks/install.yml \
        -i ansible/inventory/localhost.yml \
        -e "repo_root=$(pwd)"

# Install Windows-native packages from WSL2 (requires WinRM; see bootstrap_windows.ps1)
[windows]
install:
    WINDOWS_USER=$(cmd.exe /c 'echo %USERNAME%' 2>/dev/null | tr -d '\r\n') \
    ansible-playbook ansible/playbooks/install.yml \
        -i ansible/inventory/windows.yml \
        -e "repo_root=$(wslpath -w $(pwd))"

# Upgrade all packages, runtimes, and tools
upgrade:
    ansible-playbook ansible/playbooks/upgrade.yml \
        -i ansible/inventory/localhost.yml

# Diff declared vs installed Homebrew packages (macOS only)
diff:
    ansible-playbook ansible/playbooks/diff.yml \
        -i ansible/inventory/localhost.yml \
        -e "repo_root=$(pwd)"

# Verify the setup is complete and all tools are functional
verify:
    ansible-playbook ansible/playbooks/verify.yml \
        -i ansible/inventory/localhost.yml

# Run pre-commit checks
pre-commit:
    pre-commit install
    pre-commit run --all-files

# Installs Ansible collections
ansible-setup:
    ansible-galaxy collection install -r ansible/requirements.yml -p ./collections --force

# Lints Ansible files
ansible-lint:
    PYTHONPATH=./collections ansible-lint

# Check spelling across the repo
spellcheck:
    cspell lint --no-progress "**"
