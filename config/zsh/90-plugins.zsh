# Zsh plugins that must load last.
#
# Each plugin wraps the line editor's widgets, and zsh-syntax-highlighting has
# to wrap the finished set — its README requires it be sourced after everything
# else that binds a widget, which includes atuin and fzf in 50-tools.zsh. That
# is why this file sorts at 90.
#
# zsh-autocomplete is the exception and lives in 45-autocomplete.zsh, because
# it resets the keymap and so has the opposite constraint: it must load before
# the bindings, not after. It still precedes zsh-autosuggestions, which reads
# the completion it drives.
#
# `_setup_plugin` is defined in 45-autocomplete.zsh, which the ~/.zshrc glob
# always sources first. See there for the prefixes it searches.

_setup_plugin zsh-autosuggestions/zsh-autosuggestions.zsh
_setup_plugin zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

unset -f _setup_plugin
