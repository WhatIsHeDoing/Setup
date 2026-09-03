#!/usr/bin/env python3
"""Set one nested key in a macOS preference domain.

osx_defaults writes top-level keys only, and `defaults write -dict-add` reaches
one level down. cfprefsd caches the domain, so a PlistBuddy edit behind it can
vanish; `defaults export` and `defaults import` stay on the supported path.
Prints CHANGED or UNCHANGED for changed_when.
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
    # Intermediate dictionaries are absent until the owning pane has been opened.
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
