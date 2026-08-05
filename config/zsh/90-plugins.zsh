# Zsh plugins.
#
# Order matters and is the reason this file sorts last. Each plugin wraps the
# line editor's widgets, and zsh-syntax-highlighting has to wrap the finished
# set — its README requires it be sourced after everything else that binds a
# widget, which includes atuin and fzf in 50-tools.zsh. zsh-autocomplete goes
# first because it drives completion that zsh-autosuggestions then reads.

_setup_plugin() {
    local plugin_file="$HOMEBREW_PREFIX/share/$1"
    [[ -r $plugin_file ]] && source "$plugin_file"
}

_setup_plugin zsh-autocomplete/zsh-autocomplete.plugin.zsh
_setup_plugin zsh-autosuggestions/zsh-autosuggestions.zsh
_setup_plugin zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

unset -f _setup_plugin
