#!/bin/sh

for disk in "mysql" "photoprism" "syncthing"; do
  echo "Sending key for $disk"
  pass admin/rpi4/${disk}.luks | ssh root@rpi4.pug-coho.ts.net "cat >/run/keys/${disk}.luks"
done

echo "Unlocking disks"
ssh root@rpi4.pug-coho.ts.net "systemctl --no-block start unlock-disks.target"
