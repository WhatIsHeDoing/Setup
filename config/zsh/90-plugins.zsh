# Zsh plugins.
#
# Order matters and is the reason this file sorts last. Each plugin wraps the
# line editor's widgets, and zsh-syntax-highlighting has to wrap the finished
# set — its README requires it be sourced after everything else that binds a
# widget, which includes atuin and fzf in 50-tools.zsh. zsh-autocomplete goes
# first because it drives completion that zsh-autosuggestions then reads.
#
# All three package managers involved lay the plugins out identically below
# their own share directory, so one relative path serves every platform and
# the only per-machine difference is which prefix holds it (ADR-0009):
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
_setup_plugin zsh-autosuggestions/zsh-autosuggestions.zsh
_setup_plugin zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

unset -f _setup_plugin
