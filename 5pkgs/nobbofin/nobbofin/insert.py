#!/usr/bin/env python3
import re
import sys
import subprocess
from pathlib import Path
from typing import List, Dict

from nobbofin.accounts import gen_acc_list, get_dir

from datetime import date


def get_nnn_selection() -> List[Path]:
    selFile = Path("/home/enno/.config/nnn/.selection")
    if not selFile.exists():
        return []
    with selFile.open() as f:
        return [Path(p) for p in f.read().split("\0")]


def fzf_choose(choices: List[str]) -> str:
    p = subprocess.Popen(["fzf"], stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    out, err = p.communicate("\n".join(choices).encode("utf-8"))
    p.wait()
    if p.returncode != 0:
        raise Exception("fzf aborted")
    return out.decode("utf-8").strip()


def get_date(filename: str) -> date:
    if m := re.search(r"\D(\d{2})\.(\d{2})\.(\d{4})", filename):
        return date(int(m.group(3)), int(m.group(2)), int(m.group(1)))
    if m := re.search(r"(\d{4})-(\d{1,2})-(\d{1,2})\D", filename):
        return date(int(m.group(1)), int(m.group(2)), int(m.group(3)))
    if m := re.search(r"\D(\d{2})\-(\d{1,2})-(\d{4})\D", filename):
        return date(int(m.group(3)), int(m.group(2)), int(m.group(1)))
    if m := re.search(r"\D(\d{4})_(\d{2})_(\d{2})\D", filename):
        return date(int(m.group(1)), int(m.group(2)), int(m.group(3)))
    if m := re.search(r"\D(20\d{2})([01][1-9])([0-3][0-9])\D", filename):
        return date(int(m.group(1)), int(m.group(2)), int(m.group(3)))
    raise Exception("could not parse year: %s" % filename)


def move(files: List[Path], file_dt: Dict[Path, int], acc: str):
    for f in files:
        dest_dir = get_dir(acc, file_dt[f].year)
        dest_dir.mkdir(parents=True, exist_ok=True)
        dtPrefix = file_dt[f].strftime("%Y-%m-%d ")
        file_name = f.name if f.name.startswith(dtPrefix) else f"{dtPrefix}{f.name}"
        dest_file = dest_dir / Path(file_name)
        if dest_file.exists():
            raise Exception("file exists: %s" % dest_file)
        print(f, ">>>", dest_file)
        f.rename(dest_file)


def main():
    try:
        files = get_nnn_selection()
        if len(files) == 0:
            raise Exception("no files selected")

        # ensure all dates can be resolved
        file_dt = {f: get_date(f.name) for f in files}

        acc = fzf_choose([":".join(a) for a in gen_acc_list()])

        move(files, file_dt, acc)
    except Exception as ex:
        print(ex)
        input()
        sys.exit(1)


if __name__ == "__main__":
    main()
