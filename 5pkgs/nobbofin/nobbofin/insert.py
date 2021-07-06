#!/usr/bin/env python3
import locale
import re
import subprocess
import sys
from datetime import date, datetime
from io import BytesIO, StringIO
from pathlib import Path
from typing import IO, Dict, List

from nobbofin.accounts import gen_acc_list, get_dir
from pdfminer.converter import TextConverter
from pdfminer.layout import LAParams
from pdfminer.pdfinterp import PDFPageInterpreter, PDFResourceManager
from pdfminer.pdfpage import PDFPage


def pdf2txt(pdf_content: IO) -> str:
    # from https://stackoverflow.com/questions/26494211/extracting-text-from-a-pdf-file-using-pdfminer-in-python/26495057#26495057
    rsrcmgr = PDFResourceManager()
    codec = "utf-8"

    with StringIO() as retstr, TextConverter(
        rsrcmgr, retstr, codec=codec, laparams=LAParams()
    ) as device:
        interpreter = PDFPageInterpreter(rsrcmgr, device)
        password = ""
        maxpages = 0
        caching = True
        pagenos = set()

        for page in PDFPage.get_pages(
            pdf_content,
            pagenos,
            maxpages=maxpages,
            password=password,
            caching=caching,
            check_extractable=True,
        ):
            interpreter.process_page(page)
        return retstr.getvalue()


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


def get_date_from_filename(filename: str) -> date:
    if m := re.search(r"\D(\d{2})\.(\d{2})\.(\d{4})", filename):
        return date(int(m.group(3)), int(m.group(2)), int(m.group(1)))
    if m := re.search(r"(\d{4})-(\d{1,2})-(\d{1,2})\D", filename):
        return date(int(m.group(1)), int(m.group(2)), int(m.group(3)))
    if m := re.search(r"\D(\d{2})\-(\d{1,2})-(\d{4})\D", filename):
        return date(int(m.group(3)), int(m.group(2)), int(m.group(1)))
    if m := re.search(r"\D(\d{4})_(\d{2})_(\d{2})\D", filename):
        return date(int(m.group(1)), int(m.group(2)), int(m.group(3)))
    if m := re.search(r"\D(20\d{2})([01][0-9])([0-3][0-9])\D", filename):
        return date(int(m.group(1)), int(m.group(2)), int(m.group(3)))
    if m := re.search(r"(\d{2}-\d{2}-20\d{2})\D", filename):
        return datetime.strptime(m.group(1), "%d-%m-%Y").date()


def get_date_from_pdf_txt(f: Path) -> date:
    with f.open("rb") as fp:
        txt = pdf2txt(fp)

    locale.setlocale(locale.LC_TIME, "de_DE.UTF-8")
    all_months = [date(2020, m, 1).strftime("%B") for m in range(1, 13)]

    # 30 August 2021 (amazon receipt)
    if m := re.search(r"\D(\d{1,2} (" + "|".join(all_months) + r") 20\d{2})\D", txt):
        return datetime.strptime(m.group(1), "%d %B %Y").date()

    # 30.08.2021
    if m := re.search(r"\D(\d{2}\.\d{2}\.20\d{2})\D", txt):
        return datetime.strptime(m.group(1), "%d.%m.%Y").date()

    # 2021-08-30
    if m := re.search(r"\D(20\d{2}-\d{2}-\d{2})\D", txt):
        return datetime.strptime(m.group(1), "%Y-%m-%d").date()


def get_date(f: Path) -> date:
    if dt := get_date_from_filename(f.name):
        return dt

    if dt := get_date_from_pdf_txt(f):
        return dt

    raise Exception("could not get date for file %s" % f)


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
        file_dt = {f: get_date(f) for f in files}

        acc = fzf_choose([":".join(a) for a in gen_acc_list()])

        move(files, file_dt, acc)
    except Exception as ex:
        print(ex)
        input()
        sys.exit(1)


if __name__ == "__main__":
    main()
