# The same two candidates as `nvm_sh` in group_vars/all.yml.
for _setup_nvm in "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" "$NVM_DIR/nvm.sh"; do
    if [[ -s $_setup_nvm ]]; then
        source "$_setup_nvm"
        break
    fi
done
unset _setup_nvm

(( $+commands[starship] )) && eval "$(starship init zsh)"

(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"

# atuin initialises after fzf so its Ctrl-R binding wins; reversed, fzf keeps
# Ctrl-R.
if (( $+commands[fzf] )); then
    # apt fzf may predate `--zsh` and ship the files under /usr/share/doc instead.
    _setup_fzf_init="$(fzf --zsh 2>/dev/null)"
    if [[ -n $_setup_fzf_init ]]; then
        eval "$_setup_fzf_init"
    else
        for _setup_fzf_file in /usr/share/doc/fzf/examples/key-bindings.zsh \
            /usr/share/doc/fzf/examples/completion.zsh; do
            [[ -r $_setup_fzf_file ]] && source "$_setup_fzf_file"
        done
        unset _setup_fzf_file
    fi
    unset _setup_fzf_init
fi

(( $+commands[atuin] )) && eval "$(atuin init zsh)"

# Homebrew awscli ships an `_aws` completion already, which the `_comps` guard
# leaves alone; the v2 installer and apt ship only `aws_completer`. bashcompinit
# needs compinit to have run.
if (( $+commands[aws_completer] && $+functions[compdef] )) && (( ! $+_comps[aws] )); then
    autoload -Uz bashcompinit && bashcompinit
    complete -C aws_completer aws
fi
