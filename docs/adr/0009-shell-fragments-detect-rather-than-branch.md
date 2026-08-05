# ADR-0009: Shell fragments detect the machine rather than branching per platform

**Status:** Accepted
**Date:** 2026-08-05
**Extends:** [ADR-0008](0008-shell-config-as-repo-owned-fragments.md)

## Context

[ADR-0008](0008-shell-config-as-repo-owned-fragments.md) moved zsh
configuration into `config/zsh/*.zsh` and deployed it on macOS only. It closed
by naming the follow-up:

> Ubuntu gains managed shell configuration, at which point the fragments need a
> platform dimension and the Homebrew assumptions in `00-path.zsh` and
> `90-plugins.zsh` need splitting out.

Principle 1 makes that gap a defect rather than a preference: a capability on
one platform and not another is a gap. Ubuntu had no managed shell config at
all — no zsh package, no plugins, no atuin, and bash as the login shell.

Three of the eight fragments carried a macOS assumption. `00-path.zsh` derived
everything from `brew shellenv`; `90-plugins.zsh` hardcoded
`$HOMEBREW_PREFIX/share`; `50-tools.zsh` sourced nvm from the Homebrew keg. The
other five — history, options, environment, aliases, and the local override —
were already portable and had nothing to split.

The obvious reading of ADR-0008's follow-up was an overlay: `config/zsh/common/`
beside `config/zsh/darwin/` and `config/zsh/debian/`, selected by
`effective_platform`, mirroring how `roles/*/vars/` already works. Writing it
out made the cost visible. Ordering, the double-source guard, and the reasoning
behind PATH position would live in two near-identical copies of `00-path.zsh`,
of which only one gets read on any given machine — and the pair that drifts is
the pair nobody is looking at. Fragment discovery, the orphan sweep, and the
`99-local.zsh` exemption would each grow a platform term.

Then the actual differences turned out to be smaller than the mechanism
proposed to hold them:

| Assumption          | macOS                         | Ubuntu                         |
| ------------------- | ----------------------------- | ------------------------------ |
| Homebrew prefix     | `/opt/homebrew`, `/usr/local` | absent — no `brew` to find     |
| Plugin share prefix | `$HOMEBREW_PREFIX/share`      | `/usr/share`, `~/.local/share` |
| `nvm.sh`            | Homebrew keg                  | `$NVM_DIR`                     |
| pnpm global bin     | `~/Library/pnpm`              | `~/.local/share/pnpm`          |

Every row is a path that either exists on this machine or does not. None of
them needs to know which OS it is running on to answer that.

## Decision

**The fragments stay flat and undifferentiated. Each one searches the
locations it might find something in, and does nothing when it finds nothing.**

1. **`00-path.zsh` already worked.** Its `brew` loop tests two absolute paths
   and finds neither on Ubuntu, leaving `HOMEBREW_PREFIX` unset — which is what
   the existing `${HOMEBREW_PREFIX:+…}` guards were written to handle. The only
   change is a second pnpm directory, listed unconditionally.
2. **`90-plugins.zsh` searches three prefixes** — `$HOMEBREW_PREFIX/share`,
   `/usr/share`, `~/.local/share` — for one relative path per plugin. Homebrew,
   apt, and a git clone all lay the plugins out identically below their own
   share directory, so the relative path never varies.
3. **`50-tools.zsh` tries both `nvm.sh` locations**, the same pair `nvm_sh` in
   `group_vars/all.yml` already picks between, and falls back to fzf's
   `/usr/share/doc` shell files where apt ships a release predating `fzf --zsh`.
4. **The `dotfiles` role changes only its `when:`**, from
   `effective_platform == "darwin"` to `!= "windows"`. Discovery, the orphan
   sweep, and the two source hooks are untouched.
5. **Ubuntu installs what the fragments look for.** zsh, zsh-autosuggestions
   and zsh-syntax-highlighting from apt; zsh-autocomplete cloned at the tag
   Homebrew ships, since apt does not package it; atuin via cargo-binstall,
   which is already how this repository installs Rust tools apt lacks.
   `os_config` sets zsh as the login shell.

## Rationale

**The condition that matters is "is it here", not "which OS is this".** A
platform branch is a proxy for the real question, and it is a lossy one: it is
wrong on an Intel Mac without Homebrew, on a Debian box that has it, and on
every machine mid-install where the package is not there yet. Testing for the
path answers correctly in all of those, and it is the same test the fragments
were already making — `[[ -r ]]`, `[[ -x ]]`, `$+commands[…]` — applied to one
more candidate each.

**One file that both platforms read is one file that both platforms test.**
`zsh -n` covers every line on every machine, and the verification ADR-0008
argued for — assembling the shell and asserting on the result — now exercises
the same code twice rather than half of it twice. Under an overlay, the Ubuntu
copy of `00-path.zsh` would be parsed by nobody until someone logged into
Ubuntu and found it broken.

**Rejecting the split makes ADR-0008's premise stronger, not weaker.** That ADR
chose real files over YAML strings because real files can be checked. Splitting
them by platform would have halved the coverage of every check it introduced.

**The cost is honest and it is in the comments.** `90-plugins.zsh` now names
three prefixes and says which package manager each belongs to, so a reader sees
both platforms in one place instead of finding one and not knowing the other
exists. That is a real loss of focus in the file, and it is smaller than the
loss of a duplicated file that silently rots.

**Verification catches what silent guards let through.** Every mechanism here
degrades quietly: a missing plugin is skipped, an absent `brew` is a no-op.
That is correct at runtime and dangerous at install time, so `verify.yml` now
assembles the shell and asserts that all three plugins loaded and that Ctrl-R
reached atuin — one probe covering PATH order, tool init order, and plugin
resolution together, on both platforms.

## Consequences

**Positive:**

- Ubuntu has the same shell as macOS: same aliases, same history behaviour,
  same prompt, same Ctrl-R.
- No platform dimension anywhere — not in `config/zsh/`, not in fragment
  discovery, not in the orphan sweep.
- `verify.yml` gained an assertion on the assembled shell, which no previous
  run made on either platform.
- ADR-0008's "revisit if" for Ubuntu is closed, and closed more cheaply than it
  anticipated.

**Negative / tradeoffs:**

- Three fragments now mention paths that are irrelevant on the machine reading
  them. `90-plugins.zsh` searches three prefixes to find one.
- `~/Library/pnpm` sits in PATH on Ubuntu and `~/.local/share/pnpm` on macOS,
  each costing a failed stat on a lookup miss. Cheaper than the branch needed
  to tell them apart, but not free.
- zsh-autocomplete on Ubuntu is a pinned git clone, so it updates only when the
  pin in `roles/tools/tasks/debian.yml` moves — unlike the apt and Homebrew
  copies, which `upgrade.yml` carries forward.
- `fzf --zsh` is probed by running it, adding one process to shell startup on
  machines where the flag exists. Unmeasurable next to `starship init`.
- Changing the login shell takes effect at the next login, so the run that sets
  it reports success while the current session is still bash.

## Revisit if

- A third Unix platform arrives whose layout none of the search lists covers,
  making the flat file a list of special cases rather than a search.
- Ubuntu's apt gains a zsh-autocomplete package, retiring the pinned clone.
- A fragment needs behaviour that genuinely differs by platform rather than by
  what is installed — a keybinding that means something different, not a path
  that resolves somewhere different. That is the case an overlay is for, and it
  has not arrived yet.
