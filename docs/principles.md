# Principles

## 1. Support the major desktop platforms

macOS, Ubuntu, and Windows are the primary targets. Every tool, script, and
configuration must work on all three. A capability that only exists on one
platform is a gap, not a feature.

**Why:** A consistent environment reduces cognitive load when switching
between machines and ensures that setup knowledge is transferable.

**In practice:** Test changes against all three platforms before considering
them done.

## 2. Maximise consistency across platforms; allow superior drop-in replacements

Where platforms differ, prefer the same tool across all platforms. However,
if a better native alternative is a true drop-in replacement — identical interface,
compatible configuration, and no workflow changes required — prefer it over
the cross-platform default.

**Why:** Bespoke per-platform configurations diverge over time and create
maintenance burden. A developer who knows one machine should know all of them.
That said, a native tool that is strictly better and fully compatible adds
value without adding complexity.

**In practice:** Use the same CLI tools (bat, eza, ripgrep, starship) on all
platforms even when a native equivalent exists. Share configuration files
across platforms via templating where possible. Where a drop-in is used
(e.g. OrbStack instead of Docker Desktop on macOS), verify that the interface,
CLI behaviour, and config files are compatible before adopting it, and document
the substitution explicitly.

## 3. Prefer the vendor package manager, then the most popular

Use the OS-native package manager first (winget on Windows, apt on Ubuntu),
falling back to the most widely adopted community manager (Homebrew on macOS,
Scoop on Windows for tools not in winget).

**Why:** Vendor managers integrate with OS update mechanisms, security
patching, and enterprise policy. Community managers fill gaps but should not
be the default.

**In practice:** Check winget and apt before reaching for Scoop or a manual
install. Document why a non-vendor manager was chosen when it is.

## 4. Always track the latest

Operating systems and applications should be upgraded to the latest stable
release. Do not pin to old versions unless there is a documented, specific
reason.

**Why:** Security patches, performance improvements, and ecosystem
compatibility all favour staying current. Supporting old versions multiplies
maintenance cost for no benefit on personal machines.

**In practice:** Run upgrade steps as part of the standard setup invocation,
not as a separate optional step. Treat a machine that is significantly behind
as misconfigured.

## 5. Setup must be idempotent

Running any script or playbook multiple times against the same machine must
produce the same result as running it once. It must not fail, duplicate work,
or cause unintended changes on subsequent runs.

**Why:** Machines drift. Re-applying configuration is the primary mechanism
for remediation. If re-applying is unsafe or unreliable, it will not be done,
and drift will accumulate.

**In practice:** Use `--upgrade` rather than `--install`, check for existence
before creating, and prefer declarative tools that converge to desired state
over imperative scripts that apply actions blindly.

## 6. Prefer cross-platform tools; of those, prefer modern CLI implementations

When choosing between tools, favour those that work on all target platforms.
Among cross-platform candidates, prefer tools written in Rust or other modern
systems languages over legacy implementations.

**Why:** Cross-platform tools reduce the inconsistency surface. Modern
reimplementations (bat, eza, ripgrep, bottom) are typically faster, safer by
default, and actively maintained.

**In practice:** Before adopting a new tool, verify it is available on all
three platforms. If a Rust-native equivalent exists for a GNU tool, prefer it
unless there is a meaningful functional gap.

## 7. Separate concerns: runtimes, tools, and apps — in that order

Installation is divided into three distinct layers, applied sequentially:

- **Runtimes** — language and container runtimes that tools and apps depend on (Node.js, Python, Rust, Docker)
- **Tools** — CLI utilities used in development workflows (fzf, jq, just, ripgrep)
- **Apps** — GUI applications and end-user software (VS Code, Obsidian, Telegram)

**Why:** Runtimes are dependencies of tools; tools are dependencies of app
configuration. Applying them in dependency order makes failures easier to
diagnose and avoids ordering bugs.

**In practice:** Reflect this separation in configuration files, playbook
structure, and Justfile recipes. Do not install a tool before its runtime is
confirmed present.

## 8. Verify all setup where possible

Every installation and configuration step should be validated after it runs.
Do not assume success.

**Why:** Silent failures leave machines in an unknown state. A setup that
reports success but leaves broken tools is worse than one that reports failure
clearly.

**In practice:** Run `--version` or equivalent smoke tests after installing
tools. A failed
verification should halt the run and surface the error.

## 9. Configure the operating system, not just the applications

Beyond installing software, the OS itself should be configured to a known,
preferred state: shell defaults, git globals, developer-mode settings, and
system preferences.

**Why:** A bare OS with the right apps installed is not a complete
environment. System configuration is part of the setup contract, not an
afterthought left to manual steps.

**In practice:** Include OS configuration steps (git defaults, dock
preferences, WSL settings) in the same idempotent scripts as package
installation. Document any configuration that cannot be automated.

## 10. Bootstrap from a single command

A blank machine must reach a working state from one command with no prior
dependencies beyond what the OS ships with. The bootstrapper may install
prerequisites (e.g. Just, a package manager) before handing off to the main
setup, but that handoff must be automatic, not manual.

**Why:** If reaching a working state requires prior knowledge or multiple
manual steps, the setup is incomplete. The repo should be the complete and
sole source of truth for getting from zero to productive.

**In practice:** Each platform has one entry-point script that can be run
immediately after a clean OS install. Any prerequisite installation (e.g.
Homebrew, Scoop, Just) happens inside that script, not before it.

## 11. Prefer user-level installation over system-level

Install tools at the user level (Homebrew, Scoop, cargo install, pip install
--user) rather than system level (sudo apt install) wherever the package
manager and tool support it.

**Why:** User-level installs do not require elevated privileges, are
easier to manage and remove, and reduce the blast radius of a misconfigured
or malicious package. System-level installs should be the exception, not the
rule.

**In practice:** Reserve sudo/admin installs for tools that genuinely require
system integration (e.g. Docker Desktop, kernel extensions). When a tool is
available via both a system and user package manager, prefer the latter and
document exceptions.

## 12. Everything is version-controlled; no undocumented manual steps

The repository must be the complete and sole record of how a machine is
configured. Any step that is not automated must at minimum be documented in
the repo. A machine whose state cannot be reconstructed from the repo alone
is out of scope.

**Why:** Undocumented manual steps are invisible to future maintainers
(including yourself), cannot be tested, and are guaranteed to be forgotten.
Configuration drift begins the moment a step leaves the repo.

**In practice:** If a step cannot be automated yet, add it as a documented
task in the README rather than relying on memory. Aim to automate it in a
subsequent change.

## 13. Write automation code to production quality

Configuration and infrastructure code is subject to the same standards as
application code. Playbooks and scripts must be idiomatic, linted, and free
of unsafe patterns. Prefer dedicated modules over raw shell commands; set
explicit file permissions; declare whether tasks change state; guard piped
shell commands.

**Why:** Setup scripts run with elevated privileges on real machines. Sloppy
automation is a source of bugs, security risk, and subtle drift. Ansible
provides purpose-built modules and rules (ansible-lint profile `production`)
precisely to avoid these failure modes.

**In practice:** Run `ansible-lint` and `shellcheck` in CI. Use
`ansible.builtin.command` instead of `shell` unless shell features (pipes,
redirects, subshells) are genuinely needed. Always set `mode:` on file and
copy tasks. Always declare `changed_when:`. For unavoidable shell patterns
(e.g. install scripts piped to `sh`), suppress specific rules with `# noqa`
and a comment explaining why. Target the `production` ansible-lint profile.

## 14. Choose tools that developers love and that make them highly productive

The bar for including a tool is not that it merely solves a problem — it is
that it does so in a way that is genuinely enjoyable and makes the people
using it significantly more productive. Prefer tools with high developer
satisfaction, active communities, and a reputation for excellent UX and
performance. Actively replace tools in the setup when something meaningfully
better emerges.

**Why:** A setup used reluctantly is not a productive setup. Tools that
developers genuinely enjoy get used more, get learned more deeply, and
compound into a positive productivity loop over time. The difference between
a mediocre tool and a great one is not marginal — it accumulates across every
working hour.

**In practice:** When choosing between tools that solve the same problem,
weigh community signals (developer surveys, adoption trends, conference
mindshare) alongside technical merit. If a tool in the setup has a clearly
superior successor — better performance, better UX, more active development —
replace it. The goal is a setup that developers actively choose to use, not
one they merely tolerate.

## 15. Minimise the commands required to set up or update a machine

Both initial setup and ongoing updates must be achievable with as few
commands as possible — ideally one. Operational friction compounds over time;
a process that requires multiple steps will be deferred, done inconsistently,
or skipped.

**Why:** The purpose of this repository is to eliminate manual effort. If
running setup or applying updates still requires remembering a sequence of
commands, the setup is not complete. The measure of success is that any
operation can be handed to someone unfamiliar with the internals and completed
correctly on the first attempt.

**In practice:** Expose a small number of high-level scripts (`install`,
`upgrade`) that cover the full operation for each platform. Individual steps —
package installation, runtime setup, OS configuration, verification — are
invoked automatically within those scripts, not separately by the user. Avoid
adding tool dependencies (e.g. a task runner) that must be satisfied before
setup can begin.
