# DO_NOT_TRACK opts out wherever tools honour it: https://consoledonottrack.com
# ~/.zshenv sources this too, so `zsh -c` and `zsh -lc` see it.
# Claude Code also stops fetching feature flags, which can disable Remote Control:
# https://code.claude.com/docs/en/env-vars
# The skills installer also stops security audits:
# https://github.com/vercel-labs/skills/blob/v1.9.0/README.md#telemetry
# Opt back in: `env -u DO_NOT_TRACK <command>`.
export DO_NOT_TRACK=1
