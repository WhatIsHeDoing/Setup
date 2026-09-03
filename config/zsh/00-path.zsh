# macOS path_helper rebuilds PATH from /etc/paths in /etc/zprofile, putting
# Homebrew below /usr/bin; ~/.zprofile sources this file after it has run.

# Sourced from both ~/.zprofile and the ~/.zshrc glob.
[[ -n ${_SETUP_PATH_APPLIED:-} ]] && return
_SETUP_PATH_APPLIED=1

# On Ubuntu neither exists and HOMEBREW_PREFIX stays unset, so the
# `${VAR:+...}` guards below drop the entries rather than expanding to /bin.
for _setup_brew in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    if [[ -x $_setup_brew ]]; then
        eval "$("$_setup_brew" shellenv)"
        break
    fi
done
unset _setup_brew

typeset -U path PATH

# PNPM_HOME must match the store the runtimes role installs into, or the two
# diverge silently.
export PNPM_HOME="$HOME/.local/share/pnpm"

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
