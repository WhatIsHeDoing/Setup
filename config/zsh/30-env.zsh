# Sorted before 50-tools.zsh: several tools read these at init.

export NVM_DIR="$HOME/.nvm"

export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/rc"

# The zoxide self-check warns on every shell about the cd alias in 40-aliases.zsh.
export _ZO_DOCTOR=0

export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --line-range :50 {}' --bind '?:toggle-preview'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --icons -L 2 {}'"

# Not exported: `export` flattens an array to a scalar.
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
