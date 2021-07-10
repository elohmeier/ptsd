# !/usr/bin/env python3

import argparse
import readline
from pathlib import Path


def rlinput(prompt, prefill=""):
    readline.set_startup_hook(lambda: readline.insert_text(prefill))
    try:
        return input(prompt)
    finally:
        readline.set_startup_hook()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("filename")
    args = parser.parse_args()
    f = Path(args.filename)
    if not f.exists():
        raise FileNotFoundError(f)

    new_f = f.parent / rlinput("filename: ", f.name)
    f.rename(new_f)


if __name__ == "__main__":
    main()
