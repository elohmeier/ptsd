#!/usr/bin/env python3

import argparse

from pathlib import Path

repl_uml = {
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


def fix_uml(filename):
    new = filename
    for k, v in repl_uml.items():
        new = new.replace(k, v)
    return new


def format_file_folder_names(path: Path):
    for p in path.glob("**/*"):
        old = p.name
        new = fix_uml(old)
        if old != new:
            print(old, ">>>", new)
            p.rename(p.parent / new)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("dir")
    args = parser.parse_args()

    format_file_folder_names(Path(args.dir))
