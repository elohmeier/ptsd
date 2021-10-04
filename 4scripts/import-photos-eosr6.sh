#!/usr/bin/env bash

set -e

udisksctl mount -b /dev/disk/by-label/EOS_DIGITAL
exiftool '-Directory<DateTimeOriginal' -d '/mnt/photos/photos/originals/eosr6/%Y/%Y-%m/%Y-%m-%d' -r /run/media/enno/EOS_DIGITAL/
udisksctl unmount -b /dev/disk/by-label/EOS_DIGITAL

ssh root@nas1.nw systemctl stop photoprism
systemctl start photoprism-index


