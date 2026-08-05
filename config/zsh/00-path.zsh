# PATH ordering.
#
# macOS is why this file exists. /etc/zprofile runs path_helper, which rebuilds
# PATH from /etc/paths and then /etc/paths.d. That puts Homebrew's bin after
# /usr/bin and demotes anything exported from ~/.zshenv to the tail, so Apple's
# older jq and less, and the BSD coreutils, would win. ~/.zprofile sources this
# file after path_helper has run — the first point at which the order can be
# corrected. See ADR-0007.
#
# Ubuntu has neither path_helper nor Homebrew, so it has nothing to correct.
# The file still loads there, because the ordering rule it encodes — user
# installs ahead of what the OS ships — holds on both, and every macOS-specific
# step below reduces to a no-op on a machine with no `brew`. See ADR-0009.

# Sourced twice: from ~/.zprofile for login shells, and from ~/.zshrc via the
# config glob so non-login interactive shells get it too. `typeset -U` already
# makes a second pass a no-op, so skip it and save a `brew shellenv` on every
# interactive shell.
[[ -n ${_SETUP_PATH_APPLIED:-} ]] && return
_SETUP_PATH_APPLIED=1

# Homebrew's prefix follows the CPU — /opt/homebrew on Apple Silicon,
# /usr/local on Intel. Ask the binary rather than assuming, and let
# `brew shellenv` set HOMEBREW_PREFIX, MANPATH, and INFOPATH. Neither path
# exists on Ubuntu, where the loop finds nothing and HOMEBREW_PREFIX stays
# unset — which is what the `${VAR:+...}` guards below key off.
for _setup_brew in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    if [[ -x $_setup_brew ]]; then
        eval "$("$_setup_brew" shellenv)"
        break
    fi
done
unset _setup_brew

# Collapse duplicates, keeping the first occurrence of each entry. Without
# this, every re-source of ~/.zshrc grows PATH.
typeset -U path PATH

# User-level installs first (principle 11), then Homebrew, then what the OS
# ships. The `${VAR:+...}` guards drop the Homebrew entries entirely on a
# machine with no brew rather than expanding to a bare "/bin".
#
# pnpm chooses its own global bin directory per platform and both are listed
# unconditionally; the one this machine lacks costs a failed stat on a PATH
# miss, which is cheaper than the branch needed to tell them apart.
path=(
    "$HOME/.local/bin"                                  # uv tools, ff, ll
    "$HOME/.cargo/bin"                                  # cargo install
    "$HOME/Library/pnpm"                                # pnpm global, macOS
    "$HOME/.local/share/pnpm"                           # pnpm global, Linux
    "$HOME/.dotnet/tools"                               # dotnet tool install
    ${HOMEBREW_PREFIX:+"$HOMEBREW_PREFIX/bin"}
    ${HOMEBREW_PREFIX:+"$HOMEBREW_PREFIX/sbin"}
    $path
)

export PATH
