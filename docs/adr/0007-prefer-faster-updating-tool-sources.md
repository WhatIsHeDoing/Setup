# ADR-0007: Prefer faster-updating authoritative tool sources over OS-bundled copies

**Status:** Accepted
**Date:** 2026-08-04
**Amended by:** [ADR-0008](0008-shell-config-as-repo-owned-fragments.md)

> **Amendment.** ADR-0008 keeps this decision intact but changes how points 2
> and 3 below are delivered. The PATH logic moved from a literal block in
> `~/.zprofile` into `config/zsh/00-path.zsh`, which `~/.zprofile` sources in
> one line. Point 3's removal of third-party installer exports was dropped
> entirely: those installers re-add their lines on the next update, so the rule
> would have fought them on every run. `00-path.zsh` prepends and `typeset -U`
> dedupes, which makes those exports inert without deleting anything.

## Context

Principle 3 says to prefer the vendor package manager, and principle 4 says to
always track the latest. On macOS those two pull in opposite directions. Apple
bundles a set of command-line tools with the OS, but ships them on the OS
release cycle rather than the upstream one, and in several cases has stopped
tracking upstream altogether:

| Tool                                    | macOS ships                                         | Upstream (Homebrew) |
| --------------------------------------- | --------------------------------------------------- | ------------------- |
| `bash`                                  | 3.2.57 (2007, frozen at the last GPLv2 tag)         | 5.3                 |
| `make`                                  | GNU Make 3.81 (2006)                                | 4.4                 |
| `jq`                                    | `jq-1.7.1-apple`, a fork carrying no upstream fixes | 1.8.2               |
| `rsync`                                 | `openrsync` — a different implementation            | rsync 3.4           |
| `less`                                  | 668, POSIX regular expressions                      | 704, PCRE2          |
| `git`                                   | Apple Git, tied to Xcode Command Line Tools         | tracks upstream     |
| `sed`, `grep`, `find`, `awk`, coreutils | BSD variants                                        | GNU equivalents     |

Two things made this worth a decision rather than a set of ad-hoc additions.

**The versions are not merely older, they are a different contract.** Apple's
`jq` is a fork frozen at 1.7.1: bugs fixed upstream will never reach it.
`openrsync` is not old rsync — it is a clean-room BSD implementation that
rejects flags such as `--info=progress2`. Bash 3.2 predates associative arrays
and `mapfile`. A script written against upstream documentation can fail on a
fully up-to-date Mac.

**The repository could not reach the newer copies even when installed.**
`/etc/zprofile` runs `/usr/libexec/path_helper`, which rebuilds PATH from
`/etc/paths` and then `/etc/paths.d`. Homebrew's entry lives in
`/etc/paths.d/homebrew`, so `/opt/homebrew/bin` lands *after* `/usr/bin`, and
anything exported from `~/.zshenv` is demoted to the tail. Measured on a clean
login shell before this change, `/opt/homebrew/bin` sat at position 17 and
`/usr/bin` at position 6; `jq`, `less`, and `python3` all resolved to Apple's
copies.

The only thing masking this was `eval "$(brew shellenv)"`, which the `dotfiles`
role wrote to `~/.zshrc`. That file is sourced for **interactive shells only**,
so scripts, LaunchAgents, `ssh host cmd`, and Ansible's own `shell:` tasks
never saw it. The repository was installing tools it could not guarantee were
being used — a silent violation of principle 8.

## Decision

**Install the upstream copy from Homebrew wherever Apple's bundled version is a
frozen fork, a different implementation, or materially behind**, and make the
repository own PATH ordering so the installed copy is the one that runs.

Concretely:

1. Add `bash`, `coreutils`, `diffutils`, `findutils`, `gawk`, `git`, `gnu-sed`,
   `grep`, `make`, and `rsync` to `roles/tools/vars/darwin.yml`, alongside the
   `jq` and `less` already there.
2. Write a managed block to `~/.zprofile` from the `dotfiles` role. `~/.zprofile`
   is sourced after `/etc/zprofile`, making it the first point at which
   `path_helper`'s ordering can be corrected. The block calls `brew shellenv`,
   sets `typeset -U path PATH` to collapse duplicates, and prepends user
   directories and the Homebrew prefix ahead of the system ones.
3. Delete `eval "$(brew shellenv)"` from `~/.zshrc`, plus the hand-written PATH
   exports that ad-hoc installers left in `~/.zshenv` and `~/.zprofile` — those
   hardcode an absolute home directory and do not reproduce on a fresh machine.
4. **Keep `libexec/gnubin` off PATH.** The GNU tools install under `g`-prefixed
   names (`gsed`, `ggrep`, `gfind`, `gmake`, `gawk`, `gdate`, `gcp`, …) and stay
   there. Ask for GNU explicitly by name.
5. Assert the ordering in `verify.yml`: resolve each plain-named override in a
   login shell and fail if it does not come from the Homebrew prefix.

### What is deliberately excluded

- **`curl`.** Apple's 8.7.1 is current enough, and the Homebrew formula is
  keg-only — adopting it would mean adding a PATH entry that shadows a working
  system tool for no concrete gain. Revisit if a missing protocol bites.
- **`zsh` (5.9), `sqlite` (3.51), `vim` (9.1), `unzip`, `screen`.** Apple's are
  current or close enough that an override adds maintenance for no benefit.
- **`openssh`.** Apple's build carries Keychain integration that upstream lacks;
  overriding it would be a regression.
- **`python3` and `openssl`.** Present in the Homebrew prefix as dependencies of
  other formulae. `uv` is the authoritative Python source per
  [ADR-0006](0006-tech-specific-runtime-managers.md); nothing here changes that.

## Rationale

**Authoritative source beats bundled convenience once the bundle stops
tracking.** Principle 3's preference for the vendor manager assumes the vendor
is shipping the same software the upstream project releases. Where Apple has
forked, frozen, or substituted, that assumption no longer holds and principle 4
governs instead. This ADR draws the line at exactly that point rather than
overriding the OS wholesale.

**Prefixed names make the override additive rather than substitutive.** Putting
`gnubin` on PATH would silently change the semantics of `sed -i`, `date`,
`readlink`, and `find` for every script on the machine — including scripts this
repository did not write and does not test. The `g`-prefix keeps GNU available
without that blast radius, at the cost of remembering the prefix.

**Three formulae are the exception, and are worth naming.** `bash`, `rsync`,
and `diffutils` install under their plain names. For `bash` and `rsync` that is
the point: a `#!/usr/bin/env bash` script should get a modern shell, and Apple's
`openrsync` is the incompatible one. `diffutils` takes `diff`, `cmp`, and
`diff3` because the formula offers no prefixed variant; GNU `diff` is a
practical superset of the BSD one, so this is acceptable, but it is a genuine
system-wide substitution and not the prefixed pattern used elsewhere.

**PATH is configuration, so it belongs in the repository.** Principle 12 says a
machine's state must be reconstructible from the repo alone. Before this change,
the search order on a working machine was an accident of which installers had
run in which order, with an absolute home directory baked into two files. That
is precisely the drift principle 12 exists to prevent.

## Consequences

**Positive:**

- Tools the repository installs are the tools that actually run — verified in a
  login shell rather than assumed.
- PATH ordering is declarative, reproducible on a fresh machine, and
  deduplicated, so re-running the playbook cannot grow the variable.
- Homebrew's copies stay current through the existing `upgrade.yml` run; Apple's
  only moved on an OS release.
- `verify.yml` now fails loudly on a PATH regression instead of silently
  handing work back to the bundled tool.

**Negative / tradeoffs:**

- Ten more formulae to install and keep updated on macOS.
- GNU tools need their `g`-prefix, which differs from Ubuntu where the same
  tools are the unprefixed default. This is an accepted divergence from
  principle 2 — the alternative, `gnubin` on PATH, changes behaviour for
  untested third-party scripts.
- `bash`, `rsync`, `diff`, `cmp`, and `diff3` now resolve to Homebrew for
  everything on the machine, not just this repository's scripts.
- The `~/.zprofile` block is Ansible-managed. Hand-edits inside the markers are
  overwritten on the next run; changes belong in
  `roles/dotfiles/tasks/main.yml`.
- `/etc/paths.d/homebrew` is left in place as a fallback for non-zsh and GUI
  contexts. It still orders Homebrew after `/usr/bin`, so any context that does
  not source `~/.zprofile` retains the old behaviour.

## Revisit if

- Apple resumes tracking upstream for a tool listed here, making the override
  redundant.
- A non-login, non-interactive context (a LaunchAgent, a CI runner) needs the
  corrected order often enough to justify duplicating the block into
  `~/.zshenv`, accepting `path_helper` re-demoting it for login shells.
- Ubuntu or Windows develop the same divergence, at which point the decision
  should generalise beyond macOS rather than being reasoned out a second time.
- The `g`-prefix proves a persistent friction in daily use, making the
  `gnubin`-on-PATH tradeoff worth reopening with evidence.
