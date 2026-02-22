# Contributing

## Setup

Install pre-commit hooks after cloning:

```sh
pre-commit install
```

## Making Changes

### Adding a tool

1. Add the package name to `ansible/roles/tools/vars/{darwin,debian,windows}.yml`
2. If it requires a custom installer on any platform, add a check-and-install task to `ansible/roles/tools/tasks/{darwin,debian,windows}.yml`
3. Add a `--version` entry to `ansible/playbooks/verify.yml`
4. Update the Tools table in `README.md`

### Adding an app

1. Add the package name to `ansible/roles/apps/vars/{darwin,debian,windows}.yml`
2. Update the Apps table in `README.md`

### Adding a cross-platform package (cargo / pip / npm)

Edit `ansible/inventory/group_vars/all.yml` and update the relevant table in `README.md`.

### Documenting a decision

Add a new ADR to `docs/adr/` following the existing format and numbered sequentially. ADRs are append-only — supersede rather than edit past decisions.

## Testing

Run linting before pushing:

```sh
pre-commit run --all-files
```

Test the install playbook locally:

```sh
ansible-playbook ansible/playbooks/install.yml \
    -i ansible/inventory/localhost.yml \
    -e "repo_root=$(pwd)"
```

## Commit Style

Use the imperative mood in commit subjects (`Add bat`, not `Added bat`). No enforced format beyond that.
