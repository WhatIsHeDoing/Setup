#!/usr/bin/env python3
"""Set the default skin tone the macOS emoji picker offers for every emoji.

cfprefsd caches the domain, so an edit behind it, such as PlistBuddy, can be
discarded; `defaults export` and `defaults import` stay on the supported path.
EMFSkinToneBaseKeyPreferences is undocumented, so re-check it after a macOS
upgrade.
"""

from __future__ import annotations

import argparse
import plistlib
import subprocess
import sys
from pathlib import Path

DOMAIN = "com.apple.EmojiPreferences"
DEFAULTS_KEY = "EMFDefaultsKey"
SKIN_TONE_KEY = "EMFSkinToneBaseKeyPreferences"

SKIN_TONES = {
    "light": "\U0001f3fb",
    "medium-light": "\U0001f3fc",
    "medium": "\U0001f3fd",
    "medium-dark": "\U0001f3fe",
    "dark": "\U0001f3ff",
}
"""The Fitzpatrick modifiers U+1F3FB to U+1F3FF, under the names Apple uses."""

VARIATION_SELECTOR = "️"
"""U+FE0F; a modifier already forces emoji presentation, so a toned base drops it."""

DEFAULT_BASES_FILE = Path(__file__).with_name("emoji-modifier-bases.txt")


def read_base_emoji(bases_file: Path) -> list[str]:
    """Read the vendored base sequences, ignoring comments and blank lines."""
    lines = bases_file.read_text(encoding="utf-8").splitlines()
    return [line for line in lines if line and not line.startswith("#")]


def apply_tone(base: str, tone: str) -> str:
    """Build the toned sequence for one base emoji.

    The modifier replaces the presentation selector, matching every single-tone
    sequence in Unicode emoji-test.txt.
    """
    remainder = base[1:]
    if remainder.startswith(VARIATION_SELECTOR):
        remainder = remainder[1:]
    return base[0] + tone + remainder


def export_domain() -> dict:
    """Read the whole preference domain through cfprefsd."""
    exported = subprocess.run(
        ["defaults", "export", DOMAIN, "-"],
        capture_output=True,
        check=True,
    )
    return plistlib.loads(exported.stdout)


def import_domain(preferences: dict) -> None:
    """Write the whole preference domain back through cfprefsd."""
    subprocess.run(
        ["defaults", "import", DOMAIN, "-"],
        input=plistlib.dumps(preferences),
        check=True,
    )


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument(
        "--tone",
        required=True,
        choices=sorted(SKIN_TONES),
        help="skin tone to apply to every emoji that accepts a modifier",
    )
    parser.add_argument(
        "--preserve-existing",
        dest="should_preserve_existing",
        action="store_true",
        help="leave emoji that already carry a tone alone, filling only the gaps",
    )
    parser.add_argument(
        "--bases-file",
        type=Path,
        default=DEFAULT_BASES_FILE,
        help=f"list of base emoji to tone (default: {DEFAULT_BASES_FILE.name})",
    )
    parser.add_argument(
        "--check",
        dest="is_check_only",
        action="store_true",
        help="report drift without writing, for the verify playbook",
    )
    arguments = parser.parse_args()

    tone = SKIN_TONES[arguments.tone]
    base_emoji = read_base_emoji(arguments.bases_file)

    preferences = export_domain()
    # Both levels are absent on a machine whose picker has never been opened.
    defaults = preferences.setdefault(DEFAULTS_KEY, {})
    tone_preferences = defaults.setdefault(SKIN_TONE_KEY, {})

    changed_count = 0
    for base in base_emoji:
        if arguments.should_preserve_existing and base in tone_preferences:
            continue
        toned = apply_tone(base, tone)
        if tone_preferences.get(base) != toned:
            tone_preferences[base] = toned
            changed_count += 1

    if arguments.is_check_only:
        if changed_count == 0:
            print(f"OK: all {len(base_emoji)} emoji set to {arguments.tone} skin tone")
        else:
            print(
                f"DRIFT: {changed_count} of {len(base_emoji)} emoji "
                f"not set to {arguments.tone} skin tone"
            )
        return 0

    if changed_count == 0:
        print(f"UNCHANGED: all {len(base_emoji)} emoji already set to {arguments.tone}")
        return 0

    import_domain(preferences)
    print(f"CHANGED: set {changed_count} emoji to {arguments.tone} skin tone")
    print("Log out and back in for the emoji picker to read the new defaults.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
