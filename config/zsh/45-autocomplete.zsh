# zsh-autocomplete runs `bindkey -A emacs main` at load, discarding every
# binding already on `main`, so it sorts ahead of 50-tools.zsh.

# 90-plugins.zsh reuses `_setup_plugin`, then removes it. The prefixes are the
# Homebrew share, the apt /usr/share, and the clone the tools role makes on
# Ubuntu.
_setup_plugin() {
    local prefix
    for prefix in ${HOMEBREW_PREFIX:+"$HOMEBREW_PREFIX/share"} /usr/share "$HOME/.local/share"; do
        if [[ -r $prefix/$1 ]]; then
            source "$prefix/$1"
            return
        fi
    done
}

_setup_plugin zsh-autocomplete/zsh-autocomplete.plugin.zsh
