# Tool shell integration.
#
# Each block guards on the tool being present, so a partially installed
# machine still gets a working shell instead of an error on every prompt.
# Those same guards are what let one file serve both macOS and Ubuntu, where
# several of these arrive from a different package manager. See ADR-0009.

# nvm ships as a shell function, not a binary, so it has to be sourced.
# Homebrew keeps it in the keg on macOS; the upstream installer puts it under
# $NVM_DIR on Linux. Same two candidates as `nvm_sh` in group_vars/all.yml.
for _setup_nvm in "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" "$NVM_DIR/nvm.sh"; do
    if [[ -s $_setup_nvm ]]; then
        source "$_setup_nvm"
        break
    fi
done
unset _setup_nvm

(( $+commands[starship] )) && eval "$(starship init zsh)"

(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"

# fzf binds Ctrl-T (files), Alt-C (directories) and Ctrl-R (history). atuin
# below rebinds Ctrl-R to its own search, which is the point of installing it,
# so atuin has to initialise after fzf — reverse these two and fzf keeps
# Ctrl-R and atuin becomes unreachable from the keyboard.
if (( $+commands[fzf] )); then
    # fzf 0.48+ generates its own integration and needs nothing else. apt lags
    # upstream, and a release predating that flag ships the key-binding and
    # completion files under /usr/share/doc instead. Capture the output once
    # rather than probing for the flag and then running fzf a second time.
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

# AWS CLI completion, for the installs that do not bring their own.
#
# Homebrew's awscli formula writes an `_aws` function into its site-functions
# directory, which is already on $fpath, so macOS is complete before this runs
# and the `_comps` check below skips it. The official v2 installer and apt ship
# only `aws_completer` — a bash-style completer that zsh drives through
# bashcompinit — so those need the two lines.
#
# Guarded three ways: the completer has to exist, compinit has to have run
# (compdef is the function it defines, and bashcompinit calls it), and nothing
# may have claimed `aws` already. That last guard is what keeps this from
# overriding a better completion rather than filling a gap.
if (( $+commands[aws_completer] && $+functions[compdef] )) && (( ! $+_comps[aws] )); then
    autoload -Uz bashcompinit && bashcompinit
    complete -C aws_completer aws
fi
