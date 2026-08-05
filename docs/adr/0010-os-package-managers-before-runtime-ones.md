# ADR-0010: Prefer OS package managers over language runtime managers

**Status:** Accepted
**Date:** 2026-08-05

## Context

Six managers install packages here: Homebrew, apt and WinGet at the OS level,
cargo, uv and pnpm at the runtime level. Where both levels carry the same
package, nothing recorded which to reach for, so each tool was argued from
scratch as it landed. Two symptoms:

- **`bottom` installs twice on Windows.** `Clement.bottom` comes from WinGet in
  `roles/tools/vars/windows.yml`, and `bottom` comes from cargo in
  `cargo_packages`, which `roles/runtimes/tasks/windows.yml` also applies.
- **`atuin` and `ripgrep-all` already follow an unwritten rule** — Homebrew on
  macOS, cargo elsewhere — but the reasoning sits in a comment in `all.yml`
  rather than a decision, so it does not generalise to the next tool.

Principle 3 prefers the vendor manager, and
[ADR-0007](0007-prefer-faster-updating-tool-sources.md) already carved out the
case where the OS *bundles* a frozen copy. Neither addresses two managers both
offering a current copy.

**Homebrew turns out to sit at upstream parity, so the choice is rarely about
version at all.** Measured against crates.io, npm and PyPI on 2026-08-05:

| Package          | Upstream | Homebrew                    | Source chosen |
| ---------------- | -------- | --------------------------- | ------------- |
| `bottom`         | 0.14.7   | 0.14.7                      | Homebrew      |
| `cargo-outdated` | 0.19.0   | 0.19.0                      | Homebrew      |
| `cargo-update`   | 22.1.1   | 22.1.1                      | Homebrew      |
| `diskonaut`      | 0.11.0   | 0.11.0                      | Homebrew      |
| `wasm-pack`      | 0.15.0   | 0.15.0                      | Homebrew      |
| `cargo-modules`  | 0.27.0   | no formula                  | cargo         |
| `cspell`         | 10.0.1   | 10.0.1, depends on `node`   | pnpm          |
| `ansible-lint`   | 26.6.0   | 26.6.0, needs `python@3.14` | uv            |
| `commitizen`     | 4.17.0   | 4.17.0, needs `python@3.14` | uv            |
| `yamllint`       | 1.38.0   | 1.38.0, needs `python@3.14` | uv            |
| `checkov`        | 3.3.9    | 3.3.0                       | uv            |
| `ansible-core`   | 2.21.2   | no formula                  | uv            |

Two rows carry the whole argument for the exception. **`checkov` shipped 43
releases in 180 days** and Homebrew trails by nine of them — a formula bumped
weekly cannot track a package released twice a week. **`cspell` and the three
Python tools are at parity, and still lose**, because their formulae depend on
`node` and `python@3.14`. Installing them would put a second Node and a second
Python on a machine where [ADR-0006](0006-tech-specific-runtime-managers.md)
made nvm and uv authoritative.

**apt inverts the picture.** Ubuntu freezes an LTS at release, so on noble
`ansible-lint` is 6.17.2 against upstream 26.6.0, and `yamllint` is 1.33.0
against 1.38.0. Homebrew and WinGet roll; an LTS archive does not.

## Decision

**Install from the OS package manager — Homebrew, apt or WinGet — unless one of
three conditions holds, in which case use the runtime manager.**

1. **No OS package exists** on that platform.
2. **The OS copy's cadence is materially behind upstream**, as with `checkov`
   and everything fast-moving in an Ubuntu LTS archive.
3. **The OS copy would install a second copy of a runtime this repo already
   manages** — a Homebrew formula depending on `node` or `python@3.x` fights
   ADR-0006 rather than complementing it.

Because the conditions are per-platform, one package may legitimately come from
three sources: `bottom` is Homebrew on macOS, WinGet on Windows, cargo on Ubuntu.
The `cargo_packages_*` list suffixes already encode exactly that split.

**Removing the superseded copy is part of the move, not a follow-up.**
`config/zsh/00-path.zsh` puts `~/.cargo/bin` ahead of the Homebrew prefix, so a
machine that installed `bottom` from cargo before this change keeps resolving to
that copy — which nothing upgrades once the crate leaves `cargo_packages`. The
`runtimes` role now uninstalls the crates it hands to Homebrew and WinGet,
guarded on `cargo install --list` so it is a no-op everywhere else.

### Considered and refused

- **Reordering PATH to put Homebrew ahead of `~/.cargo/bin`** instead of
  uninstalling. It would fix the shadowing without touching any crate, but it
  demotes every user-level install to satisfy one migration, against principle
  11 and ADR-0007's ordering.
- **Keeping cargo subcommands on cargo for cohesion.** `cargo-outdated` and
  `cargo-update` extend the Rust toolchain, which argues for installing them
  with it. Rejected: cargo dispatches to any `cargo-*` on PATH regardless of
  origin, so the cohesion is aesthetic, and neither formula depends on `rust` at
  runtime. `cargo-modules` stays on cargo only because no formula exists.

## Consequences

**Positive:**

- Windows stops installing `bottom` twice from two managers.
- The rule for the next tool is one table lookup rather than a fresh argument,
  and it names *which* manager wins rather than leaving it to whoever adds it.
- macOS gains five bottled formulae in place of five cargo builds, so a fresh
  run needs no compiler for them.

**Negative / tradeoffs:**

- **A package may now be defined in three files.** `bottom` appears in
  `homebrew_tools`, `winget_tools` and `cargo_packages_debian`, and a version
  question means checking which platform is asking.
- **`cargo_packages` is down to one entry**, so the all-platform list barely
  earns its name. It stays because the next cargo-only tool belongs there.
- **The cleanup task is one-shot work carried indefinitely.** It exists for
  machines provisioned before this change and will be dead weight on every
  machine built after it.
- **`upgrade.yml` still runs all five upgrade paths**, so this consolidates
  where packages come from without reducing what an upgrade has to do.
- **Homebrew parity is a snapshot, not a guarantee.** The table above holds on
  one date; a formula that falls behind moves the package under condition 2, and
  nothing detects that automatically.

## Revisit if

- A formula listed above starts trailing upstream by more than a patch release,
  making condition 2 fire for it.
- Homebrew drops the `node` or `python@3.x` runtime dependency from `cspell` or
  the Python tools — most likely by shipping a standalone binary — which retires
  condition 3 for them.
- WinGet or apt gains packages for the tools currently reaching Windows and
  Ubuntu through cargo, at which point those `cargo_packages_*` lists shrink.
- The three-file split for a single package causes a real drift incident, which
  would argue for one platform-keyed mapping per package instead of one list per
  manager.
