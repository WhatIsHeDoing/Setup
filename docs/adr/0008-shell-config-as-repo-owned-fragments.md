# ADR-0008: Shell configuration as repo-owned fragments, not line-level edits

**Status:** Accepted
**Date:** 2026-08-05

## Context

The `dotfiles` role managed `~/.zshrc` with 19 `lineinfile` and `blockinfile`
tasks — one per setting. Each carried a `regexp` to match its own previous
output, a `line` holding shell code inside a YAML string, and the same
`create`/`mode`/`when` boilerplate. Adding an alias meant adding a task.

Every other configuration file in the repository already works the other way.
`starship.toml`, `bottom.toml`, `bat/config`, `ripgrep/rc`, `gitignore_global`
and `ghostty` live as real files under `config/` and deploy with a single
`copy`. Shell configuration was the sole exception, and the exception cost
more than the pattern it avoided:

**The content was invisible to every tool.** Shell code inside a YAML string
gets no syntax highlighting, no `zsh -n` parse check, no formatter. Two live
bugs had gone unnoticed as a direct result:

- `alias ls='eza --icons'`. eza's `--icons` takes an *optional* `WHEN` value,
  so a bare flag swallows the next argument and `ls /tmp` failed outright with
  `invalid value '/tmp' for '--icons'`. Correct spelling: `--icons=auto`.
- `export ZSH_AUTOSUGGEST_STRATEGY=(history completion)`. The variable is an
  array, and `export` flattens it to a scalar, so zsh-autosuggestions read one
  unrecognised strategy rather than two valid ones.

**Ordering was implicit and wrong.** `lineinfile` appends in task order, so the
load sequence was an accident of the order tasks happened to sit in the file.
zsh-syntax-highlighting must wrap the finished set of line-editor widgets and
its README requires it be sourced last; it was sourced before zoxide, fzf and
atuin. Nothing recorded that this mattered, so nothing stopped it drifting.

**The regexes could not tell the role's own output from a hand edit.** They
matched on fragments like `brew shellenv` or `FZF_DEFAULT_OPTS=` anywhere in
the file. ADR-0007 pushed this further by adding `state: absent` rules aimed at
lines that *third-party installers* write — uv, the .NET SDK, cargo. Those
installers re-add their lines on the next update, so the role would have
removed them again on every run: whack-a-mole encoded as configuration.

## Decision

**Shell configuration lives in `config/zsh/*.zsh` as ordinary files. The role
deploys them and adds exactly one source hook to each startup file.**

| Fragment         | Holds                                                           |
| ---------------- | --------------------------------------------------------------- |
| `00-path.zsh`    | Homebrew prefix detection, PATH ordering (ADR-0007)             |
| `10-history.zsh` | `HISTSIZE`, `HISTFILE`, `HIST_*` options                        |
| `20-options.zsh` | `AUTO_CD`, `CORRECT`, `NO_BEEP`                                 |
| `30-env.zsh`     | `NVM_DIR`, `FZF_*`, `RIPGREP_CONFIG_PATH`, autosuggest strategy |
| `40-aliases.zsh` | Aliases                                                         |
| `50-tools.zsh`   | nvm, starship, zoxide, fzf, atuin initialisation                |
| `90-plugins.zsh` | zsh-autocomplete, autosuggestions, syntax-highlighting          |
| `99-local.zsh`   | Machine-specific overrides; seeded once, never overwritten      |

Supporting rules:

1. **Numeric prefixes encode load order**, because the glob sorts. PATH first,
   since everything else depends on it. Plugins last, so syntax-highlighting
   wraps every widget the earlier fragments bound. Within `50-tools.zsh`, fzf
   initialises before atuin — both bind Ctrl-R, and atuin is meant to win.
2. **`~/.zprofile` sources `00-path.zsh` only.** Login shells need PATH fixed
   before `~/.zshrc` runs, and `~/.zprofile` is the first file zsh reads after
   `/etc/zprofile`'s `path_helper`. The fragment guards against being sourced
   twice.
3. **`~/.zshrc` sources the whole directory** with a `(N)` glob qualifier, so
   an empty or missing directory yields no error rather than a broken shell.
4. **The role prunes orphans.** A fragment renamed in the repo would otherwise
   keep loading from a previous run. `99-local.zsh` is exempt.
5. **No `backup:` on the fragments.** The repo is their source of truth, and a
   backup file written beside them would land in the directory `~/.zshrc`
   globs.
6. **The role does not delete lines written by third-party installers.**
   `00-path.zsh` prepends and `typeset -U` dedupes, so their PATH exports are
   already inert. Deleting them is a fight the repo cannot win.

## Rationale

**A real file is testable; a YAML string is not.** `zsh -n` parses every
fragment, `zsh -i -l -c` exercises the whole set, and the two bugs above were
found by running exactly those checks against content that had been shipping
for months. That is the entire argument: the pattern makes verification
possible, and verification immediately paid.

**Order becomes a property of the layout rather than of task sequence.** A
numeric prefix states the constraint in the filename, where it survives someone
reordering tasks. The two ordering rules that actually matter — plugins last,
atuin after fzf — are now written down beside the code they govern.

**One hook is auditable; 19 regexes are not.** A reader can see the whole of
what the repo does to `~/.zshrc` in six lines. Reviewing the old arrangement
meant reading 19 regexes and simulating their interaction with a file whose
prior contents were unknown.

**A seeded local file makes ownership honest.** The failure mode of a repo
owning a dotfile is that it has nowhere to put what it does not own. Migrating
this machine surfaced three genuinely personal settings — a Bitwarden agent
socket, a token limit, a zoxide flag — sitting among the managed lines with no
way to tell them apart. `99-local.zsh` gives them a home the role will not
overwrite, and it sorts last so it can override anything.

**This is the repo's existing pattern, not a new one.** `config/` and a `copy`
task is how every other tool is configured here. Extending it to zsh removes a
special case rather than adding one.

## Consequences

**Positive:**

- Shell config is syntax-checkable, diffable, reviewable, and editable in an
  editor that understands it.
- Adding a setting means editing a file, not adding an Ansible task.
- The role shrank from 19 `lineinfile`/`blockinfile` tasks to two `blockinfile`
  hooks plus a deploy loop.
- Load order is explicit and documented where it is enforced.
- Two latent bugs fixed, and a third — atuin losing Ctrl-R — caught during
  migration by testing the assembled shell rather than the tasks.
- Machine-specific settings have a durable home.

**Negative / tradeoffs:**

- `~/.zshrc` is now nearly empty, so anyone looking there for a setting has to
  follow the source line. The block comment points at `~/.config/zsh/`.
- The migration tasks in `roles/dotfiles/vars/main.yml` carry a list of the
  old managed patterns, which is exactly the fragile matching this ADR argues
  against. It is bounded, it only matches the role's own past output, and it
  is deleted once machines have converged — but it exists in the meantime.
  **Resolved 2026-08-05:** every machine has converged, so the three pattern
  lists and the six tasks that consumed them are gone. `vars/main.yml` now
  holds only the fragment glob and the local-override path.
- Sourcing eight files costs marginally more than sourcing one. Unmeasurable
  next to the `eval "$(starship init zsh)"` subshells already there.
- The pattern is macOS-only for now. Ubuntu still has no managed shell config;
  extending it there is the obvious follow-up.

## Revisit if

- ~~Ubuntu gains managed shell configuration, at which point the fragments need
  a platform dimension and the Homebrew assumptions in `00-path.zsh` and
  `90-plugins.zsh` need splitting out.~~ **Closed by
  [ADR-0009](0009-shell-fragments-detect-rather-than-branch.md):** Ubuntu now
  runs these fragments, and no platform dimension was needed — each one detects
  what the machine has instead of branching on which OS it is.
- Shell startup time becomes a complaint, making a compiled `.zwc` or a single
  concatenated file worth the loss in readability.
- A fragment grows past the point where one file is the right unit, which is
  the same judgement the `splitting-files` guidance applies elsewhere.
