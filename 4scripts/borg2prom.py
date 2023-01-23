#!/usr/bin/env python3


import argparse
import datetime
import json
import socket
import subprocess

import requests


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


def _prom(
    name,
    value,
    help=None,
    labels={},
):
    s = ""
    if help:
        s += "# HELP {} {}\n".format(name, help)
    s += "# TYPE {} gauge\n".format(name)
    s += "{}{{{}}} {}\n".format(
        name, ",".join(['{}="{}"'.format(k, v) for k, v in labels.items()]), value
    )
    return s


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--borg", "-b", default="borg", help="borg binary")
    parser.add_argument("--archive-name", "-n", help="archive name", required=True)
    parser.add_argument("--job-name", "-j", help="job name", required=True)
    parser.add_argument(
        "--push", "-p", help="push to prometheus pushgateway", action="store_true"
    )
    parser.add_argument(
        "--push-url",
        "-u",
        help="prometheus pushgateway url",
        default="https://htz1.pug-coho.ts.net:9091/",
    )
    args = parser.parse_args()

    metrics = []

    borg_list = _borg([args.borg, "list", "--json"])

    labels = {
        "repository_location": borg_list["repository"]["location"],
        "backup_job_name": args.job_name,
    }

    def prom(name, value, help=None):
        metrics.append(_prom(name, value, help, labels))

    prom(
        "borgbackup_archive_count",
        len(borg_list["archives"]),
        "Number of archives in the repository",
    )

    borg_info = _borg([args.borg, "info", "--json", "::{}".format(args.archive_name)])

    labels["archive_hostname"] = borg_info["archives"][0]["hostname"]
    labels["archive_username"] = borg_info["archives"][0]["username"]
    labels["archive_name"] = borg_info["archives"][0]["name"]

    # TODO: local time to utc
    prom(
        "borgbackup_last_start",
        datetime.datetime.strptime(
            borg_info["archives"][0]["start"], "%Y-%m-%dT%H:%M:%S.%f"
        ).timestamp(),
        help="Time of the last archive (unix timestamp)",
    )

    prom(
        "borgbackup_last_compressed_size",
        borg_info["archives"][0]["stats"]["compressed_size"],
        help="Compressed size of the last archive",
    )
    prom(
        "borgbackup_last_deduplicated_size",
        borg_info["archives"][0]["stats"]["deduplicated_size"],
        help="Deduplicated size of the last archive",
    )
    prom(
        "borgbackup_last_original_size",
        borg_info["archives"][0]["stats"]["original_size"],
        help="Original size of the last archive",
    )
    prom(
        "borgbackup_last_nfiles",
        borg_info["archives"][0]["stats"]["nfiles"],
        help="Number of files in the last archive",
    )
    prom(
        "borgbackup_last_duration",
        borg_info["archives"][0]["duration"],
        help="Backup duration of the last archive",
    )

    labels.pop("archive_hostname")
    labels.pop("archive_username")
    labels.pop("archive_name")
    labels["cache_path"] = borg_info["cache"]["path"]

    prom(
        "borgbackup_cache_total_chunks",
        borg_info["cache"]["stats"]["total_chunks"],
        help="Total number of chunks in the cache",
    )

    prom(
        "borgbackup_cache_total_csize",
        borg_info["cache"]["stats"]["total_csize"],
        help="Total compressed size of chunks in the cache",
    )

    prom(
        "borgbackup_cache_total_size",
        borg_info["cache"]["stats"]["total_size"],
        help="Total size of chunks in the cache",
    )

    prom(
        "borgbackup_cache_total_unique_chunks",
        borg_info["cache"]["stats"]["total_unique_chunks"],
        help="Total number of unique chunks in the cache",
    )

    prom(
        "borgbackup_cache_unique_csize",
        borg_info["cache"]["stats"]["unique_csize"],
        help="Total compressed size of unique chunks in the cache",
    )

    prom(
        "borgbackup_cache_unique_size",
        borg_info["cache"]["stats"]["unique_size"],
        help="Total size of unique chunks in the cache",
    )

    if args.push:
        res = requests.post(
            "{}/metrics/job/borgbackup/instance/{}→{}".format(
                args.push_url.rstrip("/"),
                socket.gethostname().split(".")[0],
                args.job_name,
            ),
            data="\n".join(metrics),
            timeout=10,
        )
        res.raise_for_status()
    else:
        print("\n".join(metrics))


if __name__ == "__main__":
    main()
