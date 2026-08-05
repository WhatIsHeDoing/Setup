# Shell history.
#
# atuin (50-tools.zsh) owns interactive search and keeps its own SQLite
# database, but zsh's own history file stays the fallback for anything that
# reads it directly, and for shells where atuin has not initialised.

HISTSIZE=100000
SAVEHIST=100000
HISTFILE=~/.zsh_history

setopt HIST_IGNORE_DUPS # Drop a command that repeats the one before it
setopt HIST_IGNORE_SPACE # Leading space keeps a command out of history
setopt HIST_VERIFY # Expand a !-reference for review instead of running it
setopt SHARE_HISTORY # Live-share history between concurrent shells
