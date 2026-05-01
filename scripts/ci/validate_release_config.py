#!/usr/bin/env python3
from __future__ import annotations

import argparse
import pathlib
import re
import sys


EXPECTED_PRESETS = {
    "GameDevTycoonmacOS": {
        "platform": "macOS",
        "export_path_suffix": ".app",
    },
    "GameDevTycoonWindows": {
        "platform": "Windows Desktop",
        "export_path_suffix": ".exe",
    },
}

TAG_PATTERN = re.compile(r"^v\d+\.\d+(?:\.\d+)?$")


def load_presets(path: pathlib.Path) -> dict[str, dict[str, str]]:
    presets: dict[str, dict[str, str]] = {}

    current_section = ""
    current_data: dict[str, str] = {}

    def maybe_store_current() -> None:
        if current_section.startswith("preset.") and not current_section.endswith(".options"):
            preset_name = current_data.get("name")
            if preset_name:
                presets[preset_name] = dict(current_data)

    for raw_line in path.read_text(encoding="utf-8").splitlines():
        line = raw_line.strip()
        if not line:
            continue

        if line.startswith("[") and line.endswith("]"):
            maybe_store_current()
            current_section = line[1:-1]
            current_data = {}
            continue

        if "=" not in line or line.startswith(";"):
            continue

        key, value = line.split("=", 1)
        current_data[key] = value.strip().strip('"')

    maybe_store_current()
    return presets


def validate_presets(presets: dict[str, dict[str, str]]) -> list[str]:
    errors: list[str] = []
    for name, expected in EXPECTED_PRESETS.items():
        preset = presets.get(name)
        if preset is None:
            errors.append(f"Missing export preset: {name}")
            continue

        platform = preset.get("platform")
        if platform != expected["platform"]:
            errors.append(f"Preset {name} targets {platform!r}, expected {expected['platform']!r}")

        export_path = preset.get("export_path", "")
        if not export_path.endswith(expected["export_path_suffix"]):
            errors.append(
                f"Preset {name} export_path must end with {expected['export_path_suffix']}, got {export_path!r}"
            )

    return errors


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--release-tag", default="")
    args = parser.parse_args()

    if args.release_tag and not TAG_PATTERN.fullmatch(args.release_tag):
        print(
            "Release tags must use vMAJOR.MINOR or vMAJOR.MINOR.PATCH, "
            f"got {args.release_tag!r}",
            file=sys.stderr,
        )
        return 1

    presets_path = pathlib.Path("export_presets.cfg")
    if not presets_path.exists():
        print("export_presets.cfg is missing", file=sys.stderr)
        return 1

    presets = load_presets(presets_path)
    errors = validate_presets(presets)
    if errors:
        for error in errors:
            print(error, file=sys.stderr)
        return 1

    print("Release configuration looks valid.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
