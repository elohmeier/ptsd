#!/usr/bin/env python3

import argparse
import os
from pathlib import Path

fix_uml = {
    # remove "Combining diaeresis"
    "a\u0308": "ä",
    "o\u0308": "ö",
    "u\u0308": "ü",
    "A\u0308": "Ä",
    "O\u0308": "Ö",
    "U\u0308": "Ü",
    # remove "acute accent"
    "e\u0301": "é",
}

eleminate_uml = {
    # remove "Combining diaeresis"
    "a\u0308": "ae",
    "o\u0308": "oe",
    "u\u0308": "ue",
    "A\u0308": "Ae",
    "O\u0308": "Oe",
    "U\u0308": "Ue",
    # remove "acute accent"
    "e\u0301": "e",
    "ä": "ae",
    "ö": "oe",
    "ü": "ue",
    "Ä": "Ae",
    "Ö": "Oe",
    "Ü": "Ue",
    "é": "e",
    "ß": "ss",
}


def replace(filename: str, replace_dict: dict) -> str:
    """Replace symbols in filename"""
    new = filename
    for k, v in replace_dict.items():
        new = new.replace(k, v)
    return new


def rename_folders(path: Path, replace_dict: dict, dry_run: bool) -> None:
    """Rename folders"""
    for subdir, _, _ in os.walk(path, topdown=False):
        old_bn = os.path.basename(subdir)
        new_bn = replace(old_bn, replace_dict)
        if old_bn != new_bn:
            new = os.path.join(os.path.dirname(subdir), new_bn)
            print(subdir, ">>>", new)
            if not dry_run:
                os.rename(subdir, new)


def rename_files(path: Path, replace_dict: dict, dry_run: bool) -> None:
    for p in path.glob("**/*"):
        if p.is_file():
            old = p.name
            new = replace(old, replace_dict)
            if old != new:
                print(old, ">>>", new)
                if not dry_run:
                    p.rename(p.parent / new)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--eliminate", "-e", action="store_true")
    parser.add_argument("--files-only", "-f", action="store_true")
    parser.add_argument("--folders-only", "-d", action="store_true")
    parser.add_argument("--dry-run", "-n", action="store_true")
    parser.add_argument("dir")
    args = parser.parse_args()

    repl_dict = eleminate_uml if args.eliminate else fix_uml
    dir = Path(args.dir)

    if not args.files_only:
        rename_folders(dir, repl_dict, args.dry_run)

    if not args.folders_only:
        rename_files(dir, repl_dict, args.dry_run)
