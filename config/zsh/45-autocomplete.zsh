# zsh-autocomplete, which has to load before anything that binds a key.
#
# Its initialisation runs `bindkey -A emacs main`, pointing the `main` keymap
# at a fresh `emacs` one. That discards every binding already applied to
# `main` — including atuin's Ctrl-R, which is the binding atuin exists for.
# fzf survives the same reset only by accident, because it binds `-M emacs`
# rather than `main`. Upstream's README states the rule: load zsh-autocomplete
# before the key bindings you want to keep.
#
# So this sorts at 45, ahead of 50-tools.zsh, while zsh-autosuggestions and
# zsh-syntax-highlighting stay at 90 — they have the opposite requirement and
# must wrap the finished set of widgets. See ADR-0008 rule 1.

# Shared with 90-plugins.zsh, which loads the remaining two plugins and then
# removes this helper. Both files are sourced into the same shell in glob
# order, so the definition is still live by the time 90 runs.
#
# All three package managers lay the plugins out identically below their own
# share directory, so one relative path serves every platform and the only
# per-machine difference is which prefix holds it (ADR-0009):
#
#   $HOMEBREW_PREFIX/share  Homebrew, macOS
#   /usr/share              apt, for autosuggestions and syntax-highlighting
#   ~/.local/share          the git clone the tools role makes on Ubuntu for
#                           zsh-autocomplete, which apt does not package
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
