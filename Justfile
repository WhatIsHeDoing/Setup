# Explicitly set config path — WSL2 mounts appear world-writable, causing Ansible to ignore ansible.cfg

export ANSIBLE_CONFIG := justfile_directory() + "/ansible.cfg"

set windows-shell := ["powershell.exe", "-NoProfile", "-Command"]

# Choose from all available recipes
default:
    @just --choose

# Bootstrap prerequisites on this machine (run once on a fresh machine)
[group('setup')]
bootstrap:
    #!/usr/bin/env sh
    case "$(uname -s)" in
        Darwin) bash bootstrap/bootstrap_macos.sh ;;
        Linux)  bash bootstrap/bootstrap_ubuntu.sh ;;
        *)      echo "On Windows, run: bootstrap\bootstrap_windows.ps1 in PowerShell" ;;
    esac

# Install and configure everything on this machine (macOS / Ubuntu / WSL2)
[group('ansible')]
[linux]
[macos]
install:
    ansible-playbook ansible/playbooks/install.yml \
        -i ansible/inventory/localhost.yml \
        -e "repo_root=$(pwd)"

# Install Windows-native packages from WSL2 (requires WinRM; see bootstrap_windows.ps1)
[group('ansible')]
[windows]
install:
    WINDOWS_USER=$(cmd.exe /c 'echo %USERNAME%' 2>/dev/null | tr -d '\r\n') \
    ansible-playbook ansible/playbooks/install.yml \
        -i ansible/inventory/windows.yml \
        -e "repo_root=$(wslpath -w $(pwd))"

# Upgrade all packages, runtimes, and tools
[group('ansible')]
upgrade:
    ansible-playbook ansible/playbooks/upgrade.yml \
        -i ansible/inventory/localhost.yml

# Run install for specific roles only: just install-tags dotfiles git
[group('ansible')]
install-tags +tags:
    ansible-playbook ansible/playbooks/install.yml \
        -i ansible/inventory/localhost.yml \
        -e "repo_root=$(pwd)" \
        --tags "{{ tags }}" \
        --skip-tags verify

# Preview what install would change without making any changes
[group('ansible')]
dry-run:
    ansible-playbook ansible/playbooks/install.yml \
        -i ansible/inventory/localhost.yml \
        -e "repo_root=$(pwd)" \
        --check --diff \
        --skip-tags verify

# Preview changes for specific roles only: just dry-run-tags dotfiles git
[group('ansible')]
dry-run-tags +tags:
    ansible-playbook ansible/playbooks/install.yml \
        -i ansible/inventory/localhost.yml \
        -e "repo_root=$(pwd)" \
        --check --diff \
        --tags "{{ tags }}" \
        --skip-tags verify

# Diff declared vs installed Homebrew packages (macOS only)
[group('ansible')]
diff:
    ansible-playbook ansible/playbooks/diff.yml \
        -i ansible/inventory/localhost.yml \
        -e "repo_root=$(pwd)"

# Verify the setup is complete and all tools are functional
[group('ansible')]
verify:
    ansible-playbook ansible/playbooks/verify.yml \
        -i ansible/inventory/localhost.yml

# Run all local checks: spelling, markdown lint, and Ansible lint
[group('ci')]
validate:
    cspell lint --no-progress "**"
    pre-commit run --all-files
    PYTHONPATH=./collections ansible-lint

# Run pre-commit checks
[group('ci')]
pre-commit:
    pre-commit install
    pre-commit run --all-files

# Update all pre-commit hooks to their latest versions
[group('ci')]
update-hooks:
    pre-commit autoupdate

# Installs Ansible and collections via uv (matches CI; avoids CLI/module version mismatch from brew)
[group('ci')]
ansible-setup:
    uv tool install ansible-core
    uv tool install ansible-lint
    ansible-galaxy collection install -r ansible/requirements.yml -p ./collections --force

# Lints Ansible files
[group('ci')]
ansible-lint:
    PYTHONPATH=./collections ansible-lint

# Check spelling across the repo
[group('ci')]
spellcheck:
    cspell lint --no-progress "**"
