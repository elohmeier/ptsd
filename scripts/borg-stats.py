#!/usr/bin/env python3

import argparse
import json
import subprocess


def _borg(args):
    p = subprocess.Popen(
        args,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    p.wait()
    stdout, stderr = p.communicate()
    if p.returncode != 0:
        raise RuntimeError("borg failed: {}".format(stderr.decode()))
    return json.loads(stdout)


def bytes_to_human_readable(size):
    for unit in ["", "Ki", "Mi", "Gi", "Ti", "Pi", "Ei", "Zi"]:
        if abs(size) < 1024.0:
            return "%3.1f%sB" % (size, unit)
        size /= 1024.0
    return "%.1f%sB" % (size, "Yi")


def count_to_human_readable(count):
    for unit in ["", "K", "M", "G", "T", "P", "E", "Z"]:
        if abs(count) < 1000.0:
            return "%3.1f%s" % (count, unit)
        count /= 1000.0
    return "%.1f%s" % (count, "Y")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--borg", "-b", default="borg")
    args = parser.parse_args()

    borg_list = _borg([args.borg, "list", "--json"])
    print(f"{'Archive':<40}{'Orig':>15}{'Compr':>15}{'Dedup':>15}{'nFiles':>15}")

    for archive in borg_list["archives"]:
        archive_info = _borg(
            [args.borg, "info", "--json", "::{}".format(archive["archive"])]
        )
        print(
            "{:<40}{:>15}{:>15}{:>15}{:>15}".format(
                archive["archive"],
                bytes_to_human_readable(
                    archive_info["archives"][0]["stats"]["original_size"]
                ),
                bytes_to_human_readable(
                    archive_info["archives"][0]["stats"]["compressed_size"]
                ),
                bytes_to_human_readable(
                    archive_info["archives"][0]["stats"]["deduplicated_size"]
                ),
                count_to_human_readable(
                    archive_info["archives"][0]["stats"]["nfiles"],
                ),
            )
        )


if __name__ == "__main__":
    main()
