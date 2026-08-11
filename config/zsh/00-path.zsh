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
# Point pnpm at the same global store the runtimes role installs into, so an
# interactive `pnpm add -g` and a `just install` agree on where globals live.
# Left unset, pnpm picks its own per-platform default — ~/Library/pnpm on macOS
# — and the two stores diverge without either side reporting anything.
export PNPM_HOME="$HOME/.local/share/pnpm"

# The global bin directory is `$PNPM_HOME/bin`, not `$PNPM_HOME` as older
# `pnpm setup` blocks wrote it; `pnpm bin -g` is the authority if that ever
# needs rechecking. The Library path stays listed for machines provisioned
# before this file exported PNPM_HOME, whose globals still live there — one
# failed stat on a PATH miss, against a silently missing command.
path=(
    "$HOME/.local/bin"                                  # uv tools, ff, ll
    "$HOME/.cargo/bin"                                  # cargo install
    "$PNPM_HOME/bin"                                    # pnpm global
    "$HOME/Library/pnpm/bin"                            # pnpm global, pre-PNPM_HOME machines
    "$HOME/.dotnet/tools"                               # dotnet tool install
    ${HOMEBREW_PREFIX:+"$HOMEBREW_PREFIX/bin"}
    ${HOMEBREW_PREFIX:+"$HOMEBREW_PREFIX/sbin"}
    $path
)

export PATH
