# Tool shell integration.
#
# Each block guards on the tool being present, so a partially installed
# machine still gets a working shell instead of an error on every prompt.

# nvm ships as a shell function, not a binary, so it has to be sourced.
# Homebrew keeps it in the keg rather than on PATH.
[[ -s "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" ]] && source "$HOMEBREW_PREFIX/opt/nvm/nvm.sh"

(( $+commands[starship] )) && eval "$(starship init zsh)"

(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"

# fzf 0.48+ generates its own shell integration, which replaces sourcing
# key-bindings.zsh and completion.zsh from the keg.
#
# fzf binds Ctrl-T (files), Alt-C (directories) and Ctrl-R (history). atuin
# below rebinds Ctrl-R to its own search, which is the point of installing it,
# so atuin has to initialise after fzf — reverse these two and fzf keeps
# Ctrl-R and atuin becomes unreachable from the keyboard.
(( $+commands[fzf] )) && source <(fzf --zsh)

(( $+commands[atuin] )) && eval "$(atuin init zsh)"
