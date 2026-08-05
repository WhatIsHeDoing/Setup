# Environment for tools initialised in 50-tools.zsh and 90-plugins.zsh.
# Set before those run, since several read their configuration at load time.

export NVM_DIR="$HOME/.nvm"

export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/rc"

# 40-aliases.zsh points `cd` at zoxide's `z`, which zoxide's self-check reads
# as a misconfiguration and warns about on every shell. The aliasing is
# deliberate, so silence the check rather than the shell.
export _ZO_DOCTOR=0

# fzf drives its file and directory pickers through fd, so both honour
# .gitignore and skip .git without a second exclude list to maintain.
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --line-range :50 {}' --bind '?:toggle-preview'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --icons -L 2 {}'"

# An array, so it must not be exported — `export` would flatten it to a
# scalar and zsh-autosuggestions would read a single unrecognised strategy.
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
