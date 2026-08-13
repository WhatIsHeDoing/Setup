#!/usr/bin/env python3
"""Set one nested key in a macOS preference domain.

community.general.osx_defaults writes top-level keys only, and `defaults write
-dict-add` reaches exactly one level down, so settings buried deeper — Finder
keeps its list-view options under StandardViewSettings → ListViewSettings — have
no module to write them.

PlistBuddy can reach them, but only by editing the plist file directly. cfprefsd
owns these domains and caches them in memory, so the file on disk routinely
trails what `defaults read` reports, and a write behind cfprefsd's back can
vanish when it next flushes. `defaults export` and `defaults import` move the
whole domain through cfprefsd instead, which is the supported path and leaves
every key this script does not name untouched.

Prints CHANGED or UNCHANGED so an Ansible task can set changed_when honestly
rather than falling back to changed_when: false.
"""

from __future__ import annotations

import argparse
import plistlib
import subprocess
import sys

VALUE_PARSERS = {
    "string": str,
    "integer": int,
    "float": float,
    "bool": lambda text: text.strip().lower() in {"true", "yes", "1"},
}


def export_domain(domain: str) -> dict:
    """Read the whole preference domain through cfprefsd."""
    exported = subprocess.run(
        ["defaults", "export", domain, "-"],
        capture_output=True,
        check=True,
    )
    return plistlib.loads(exported.stdout)


def import_domain(domain: str, preferences: dict) -> None:
    """Write the whole preference domain back through cfprefsd."""
    subprocess.run(
        ["defaults", "import", domain, "-"],
        input=plistlib.dumps(preferences),
        check=True,
    )


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--domain", required=True, help="preference domain to edit")
    parser.add_argument(
        "--key-path",
        required=True,
        help="colon-separated path to the key, as PlistBuddy writes it",
    )
    parser.add_argument("--value", required=True, help="value to set")
    parser.add_argument(
        "--type",
        dest="value_type",
        required=True,
        choices=sorted(VALUE_PARSERS),
        help="type to store the value as",
    )
    arguments = parser.parse_args()

    *parent_keys, leaf_key = arguments.key_path.split(":")
    value = VALUE_PARSERS[arguments.value_type](arguments.value)

    preferences = export_domain(arguments.domain)
    # Intermediate dictionaries are absent on a machine that has never opened
    # the pane owning them, so create them on the way down.
    container = preferences
    for key in parent_keys:
        container = container.setdefault(key, {})

    if container.get(leaf_key) == value:
        print(f"UNCHANGED: {arguments.domain} {arguments.key_path} is already {value!r}")
        return 0

    container[leaf_key] = value
    import_domain(arguments.domain, preferences)
    print(f"CHANGED: set {arguments.domain} {arguments.key_path} to {value!r}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
