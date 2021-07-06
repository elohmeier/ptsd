import os
import shutil
import subprocess
from pathlib import Path

import click

REPOS = {
    "nw1": {"path": "/mnt/backup/nw1/borg", "quota": "250G", "user": "borg-nw1"},
    "nw10": {"path": "/mnt/backup/nw10/borg", "quota": "400G", "user": "borg-nw10"},
}
BORG_PATH = "borg"
ZFS_PATH = "zfs"
ZPOOL_PATH = "zpool"

# nix-replace #


@click.command()
@click.option("--root", default="/", help="Root directory to work in, default is '/'")
@click.option(
    "--group", default="borg", help="group for the borg repo, default is 'borg'"
)
@click.option(
    "--borg-mode",
    default="repokey-blake2",
    help="encryption mode, default is 'repokey-blake2'",
)
@click.option("--zpool", help="zpool to create zfs volumes on, e.g. 'nw321'")
@click.option("--device", help="device to create zpool on, e.g. '/dev/sdc'")
@click.option(
    "--init-repo/--no-init-repo",
    default=True,
    help="Initialize the repo or not, default is '--init-repo' (true)",
)
@click.option(
    "--skip-existing/--no-skip-existing",
    default=True,
    help="Skip existing repos or not, default is '--skip-existing' (true)",
)
@click.option(
    "--chown/--no-chown",
    default=True,
    help="Chown the repo or not, default is '--chown' (true)",
)
@click.option(
    "--zpool-mount",
    default="/mnt/backup",
    help="mount point for created zpool, default is '/mnt/backup'",
)
def init_backup(
    root, group, borg_mode, zpool, device, init_repo, skip_existing, chown, zpool_mount
):
    if os.geteuid() != 0:
        exit("You need to have root privileges to run this script.")

    proot = Path(root)

    if device and zpool_mount:
        cmd = [
            ZPOOL_PATH,
            "create",
            "-m",
            zpool_mount,
            zpool,
            "-o",
            "feature@userobj_accounting=disabled",
            "-f",
            device,
        ]
        click.echo("To create the zpool we will execute the following command:")
        click.echo(" ".join(cmd))
        if click.confirm("DO YOU WANT TO CONTINUE???"):
            subprocess.run(cmd, check=True)

    zfs_create = zpool and click.confirm(
        "SHOULD WE CREATE THE ZFS VOLUMES USING 'zfs create'???"
    )

    for k, v in REPOS.items():
        p = proot / ("." + v["path"])

        if p.exists() and skip_existing:
            click.echo("Skipped existing repo %s" % k)
            continue

        if zfs_create:
            subprocess.run(
                [ZFS_PATH, "create", "-o", f"quota={v['quota']}", f"{zpool}/{k}"],
                check=True,
            )

        if init_repo:
            click.echo("Creating directory %s" % p)
            p.mkdir(parents=True, exist_ok=False)
            click.echo("Initializing repo %s" % k)
            clean_env = {
                k: v for k, v in os.environ.copy().items() if not k.startswith("BORG_")
            }
            subprocess.run(
                [
                    BORG_PATH,
                    "init",
                    "-e",
                    borg_mode,
                    "--storage-quota",
                    v["quota"],
                    p.resolve(),
                ],
                check=True,
                env=clean_env,
            )
        if chown:
            click.echo("Changing owner to %s" % v["user"])
            shutil.chown(p.resolve(), user=v["user"], group=group)
            for root, dirs, files in os.walk(p.resolve()):
                for d in dirs:
                    shutil.chown(os.path.join(root, d), user=v["user"], group=group)
                for f in files:
                    shutil.chown(os.path.join(root, f), user=v["user"], group=group)


if __name__ == "__main__":
    init_backup()
