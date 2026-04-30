#!/usr/bin/env python3
from __future__ import annotations

import argparse
import pathlib
import re
import sys


TAG_PATTERN = re.compile(r"^v(\d+\.\d+(?:\.\d+)?)$")


def replace_value(text: str, key: str, value: str) -> str:
    pattern = re.compile(rf'^{re.escape(key)}=".*"$', re.MULTILINE)
    replacement = f'{key}="{value}"'
    if pattern.search(text):
        return pattern.sub(replacement, text)
    return text


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--release-tag", required=True)
    parser.add_argument("--platform", choices=("macos", "windows"), required=True)
    args = parser.parse_args()

    match = TAG_PATTERN.fullmatch(args.release_tag)
    if not match:
        print(
            "Release tags must use vMAJOR.MINOR or vMAJOR.MINOR.PATCH, "
            f"got {args.release_tag!r}",
            file=sys.stderr,
        )
        return 1

    version = match.group(1)
    path = pathlib.Path("export_presets.cfg")
    text = path.read_text(encoding="utf-8")

    if args.platform == "macos":
        keys = ("application/short_version", "application/version")
    else:
        keys = ("application/file_version", "application/product_version")

    for key in keys:
        text = replace_value(text, key, version)

    path.write_text(text, encoding="utf-8")
    print(f"Stamped {args.platform} export metadata with version {version}.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
