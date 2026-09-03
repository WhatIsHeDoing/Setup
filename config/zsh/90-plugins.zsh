# zsh-syntax-highlighting must wrap the finished set of widgets, including those
# atuin and fzf bind in 50-tools.zsh, so this file sorts last. `_setup_plugin`
# comes from 45-autocomplete.zsh.

_setup_plugin zsh-autosuggestions/zsh-autosuggestions.zsh
_setup_plugin zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

unset -f _setup_plugin
