#!/usr/bin/env fish

set TARGET "u267169@u267169.your-storagebox.de"

for host in htz1 htz2 htz3 mb3 mb4 rpi4 bae0thiu;
  echo "Configuring backups/$host/.ssh/authorized_keys"
  ssh -p 23 $TARGET "mkdir -p backups/$host/.ssh"
  scp -P 23 (pass hosts/$host/nwbackup.id_ed25519.pub | psub) $TARGET:backups/$host/.ssh/authorized_keys
end
