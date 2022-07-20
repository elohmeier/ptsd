#!/usr/bin/env nix-shell
#!nix-shell -i python3 -p python3Packages.python-gnupg -p rsync

import argparse
import gnupg
import subprocess
import tempfile
import os
import logging
from pathlib import Path

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("frix-copy-secrets")


def populate_tmp_dir(tmp_dir: str, src_path: Path):
    gpg = gnupg.GPG()

    for gpg_file in src_path.glob("**/*.gpg"):
        rel_path = gpg_file.parent.relative_to(src_path)
        tmp_file = Path(tmp_dir) / rel_path / gpg_file.stem
        with gpg_file.open("rb") as f_src:
            tmp_file.parent.mkdir(parents=True, exist_ok=True)
            gpg.decrypt_file(f_src, output=tmp_file)


def copy_secrets(pass_store_dir: str, src: str, dst: str):
    logger.info("copying from %s/%s to %s", pass_store_dir, src, dst)

    src_path = Path(pass_store_dir) / src
    if not src_path.is_dir() or not src_path.exists():
        raise Exception("src_path %s does not exist", src_path)

    with tempfile.TemporaryDirectory() as tmp_dir:
        logger.debug("tmp_dir: %s", tmp_dir)
        populate_tmp_dir(tmp_dir, src_path)

        logger.info("files decrypted, rsyncing to %s", dst)
        subprocess.run(
            [
                "rsync",
                "-vr",
                "--delete",
                "--chmod=Du=rx,Dg=,Do=,Fu=r,Fg=,Fo=",
                tmp_dir + "/",
                dst,
            ],
            check=True,
        )
    logger.info("files copied successfully")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--pass-store-dir", default=os.getenv("PASSWORD_STORE_DIR"))
    parser.add_argument("src")
    parser.add_argument("dst")
    args = parser.parse_args()

    copy_secrets(args.pass_store_dir, args.src, args.dst)
