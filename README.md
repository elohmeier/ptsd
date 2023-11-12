# ptsd

Public [Nix](https://nixos.org/nix/) configurations.


## AWS builder
- `aws ec2 import-key-pair --key-name tp1 --public-key-material fileb://~/.ssh/id_ed25519.pub`
- `aws ec2 run-instances --image-id ami-0b9c95d926ab9474c --instance-type a1.4xlarge --key-name tp1 --security-groups allow-all --block-device-mappings 'DeviceName=/dev/xvda,Ebs={VolumeSize=40}'`
- accept ssh host key as user & root
- `nix build .#nixosConfigurations.pine2_sdimage.config.system.build.kernel --builders 'ssh://root@18.193.85.42 aarch64-linux - 96 - big-parallel' --max-jobs 0 --builders-use-substitutes`



## Setup

Add the ptsd channel using

```console
$ nix-channel --add https://git.nerdworks.de/nerdworks/ptsd/archive/master.tar.gz ptsd
$ nix-channel --update
```

## Hacking on ptsd

Make sure to remove the ptsd channel first to avoid conflicts.
Then include local checkout of ptsd in nix builds by altering the NIX\_PATH variable.

E.g. to use local checkout in home-manager:

```console
NIX_PATH=$NIX_PATH:ptsd=$HOME/ptsd home-manager build
```

or when rebuilding using sudo:

```console
sudo nixos-rebuild -I ptsd=$HOME/ptsd build
```


## Provision Hetzner VM


### with disk-encryption

Setup disk
```bash
export pass="YOURPASSWORD"

sgdisk -og -a1 -n1:2048:+200M -t1:8300 -n3:-1M:0 -t3:EF02 -n2:0:0 -t2:8309 /dev/sda
echo -n $pass | cryptsetup -q luksFormat /dev/sda2
echo -n $pass | cryptsetup luksOpen /dev/sda2 sda2_crypt
pvcreate /dev/mapper/sda2_crypt
vgcreate vg /dev/mapper/sda2_crypt
lvcreate -L 1G -n root vg
lvcreate -L 6G -n nix vg
lvcreate -L 2G -n var vg
lvcreate -L 1G -n var-log vg
lvcreate -L 2G -n var-src vg
mkfs.ext4 -F /dev/vg/root
mkfs.ext4 -F /dev/vg/nix
mkfs.ext4 -F /dev/vg/var
mkfs.ext4 -F /dev/vg/var-log
mkfs.ext4 -F /dev/vg/var-src
mkfs.ext4 -F /dev/sda1
mount /dev/vg/root /mnt/
mkdir /mnt/{boot,nix,var}
mount /dev/sda1 /mnt/boot
mount /dev/vg/nix /mnt/nix
mount /dev/vg/var /mnt/var
mkdir /mnt/var/{log,src}
mount /dev/vg/var-log /mnt/var/log
mount /dev/vg/var-src /mnt/var/src
mkdir /mnt/var/src/.populate
nix-env -iA nixos.pkgs.gitMinimal
```


### without disk-encryption

```bash
sgdisk -og -a1 -n1:2048:+200M -t1:8300 -n3:-1M:0 -t3:EF02 -n2:0:0 -t2:8300 /dev/sda
pvcreate /dev/sda2
vgcreate vg /dev/sda2
lvcreate -L 1G -n root vg
lvcreate -L 6G -n nix vg
lvcreate -L 2G -n var vg
lvcreate -L 1G -n var-log vg
lvcreate -L 2G -n var-src vg
mkfs.ext4 -F /dev/vg/root
mkfs.ext4 -F /dev/vg/nix
mkfs.ext4 -F /dev/vg/var
mkfs.ext4 -F /dev/vg/var-log
mkfs.ext4 -F /dev/vg/var-src
mkfs.ext4 -F /dev/sda1
mount /dev/vg/root /mnt/
mkdir /mnt/{boot,nix,var}
mount /dev/sda1 /mnt/boot
mount /dev/vg/nix /mnt/nix
mount /dev/vg/var /mnt/var
mkdir /mnt/var/{log,src}
mount /dev/vg/var-log /mnt/var/log
mount /dev/vg/var-src /mnt/var/src
mkdir /mnt/var/src/.populate
nix-env -iA nixos.pkgs.gitMinimal
```


### unmount & reboot

```bash
umount /mnt/var/{src,log}
umount /mnt/{boot,nix,var}
umount /mnt
reboot
```


## Provision AWS remote builder

1. Configure instance, allow SSH access, configure large enough disk (e.g. 20GB), use [ami-0886e2450125a1f08](https://wiki.debian.org/Cloud/AmazonEC2Image/Buster)
2. Login via ssh to instance as admin user
3. Install rsync & git: `sudo apt update && sudo apt install -y rsync git`
4. Install nix in multi user mode: `sh <(curl -L https://nixos.org/nix/install) --daemon`
5. Fix PATH: `echo 'PATH=/nix/var/nix/profiles/default/bin:/usr/local/bin:/usr/bin:/bin' | sudo tee -a /etc/environment`
6. Configure nix: `echo 'trusted-users = admin\nmax-jobs = 8' | sudo tee -a /etc/nix/nix.conf && sudo systemctl restart nix-daemon.service`
7. On dev machine, add SSH-Key: `ssh-copy-id -f -i /run/keys/ssh.id_ed25519.pub awsbuilder`
8. Accept host public key for root user: `sudo ssh awsbuilder`


## Tips

### /var/src requirements

Ensure at least 100k inodes (e.g. by tuning the bytes-per-inode ratio as in `mkfs.ext4 -i 2048 /dev/sysVG/var-src` for a 300M drive.)

### Get predictable network interface name
[as used by systemd](https://www.freedesktop.org/wiki/Software/systemd/PredictableNetworkInterfaceNames/)
e.g. `udevadm test-builtin net_id /sys/class/net/enp39s0`

### Quick deployment of package needing compilation
`nix-copy-closure --to root@apu2 $(nix-build -E 'with import <nixpkgs> {}; callPackage ./5pkgs/nwhass {}')`

### Force cert renewal
Add `security.acme.validMinDays = 999;` to your config and rebuild. Remember to remove it again...

## Generate TLSA DANE record for mailserver

Run `tlsa --port 25 --starttls smtp --create htz2.nn42.de --selector 1` to generate updated hash from mailserver certificate.

Or run `nix-shell -p gnutls.bin --run "danetool --tlsa-rr --host htz2.nn42.de --port 25 --load-certificate /var/lib/acme/htz2.nn42.de/cert.pem"` on htz2.

Run `check_ssl_cert -H htz2.nn42.de -p 25 -P smtp --dane 1` to check it.




## Upgrade postgres

```
  environment.systemPackages =
    let newpg = pkgs.postgresql_13;
    in [
      (pkgs.writeScriptBin "upgrade-pg-cluster" ''
        set -x
        export OLDDATA="${config.services.postgresql.dataDir}"
        export NEWDATA="/var/lib/postgresql/${newpg.psqlSchema}"
        export OLDBIN="${config.services.postgresql.package}/bin"
        export NEWBIN="${newpg}/bin"

        install -d -m 0700 -o postgres -g postgres "$NEWDATA"
        cd "$NEWDATA"
        sudo -u postgres $NEWBIN/initdb -D "$NEWDATA" --locale=de_DE.UTF-8

        systemctl stop postgresql    # old one

        sudo -u postgres $NEWBIN/pg_upgrade \
          --old-datadir "$OLDDATA" --new-datadir "$NEWDATA" \
          --old-bindir $OLDBIN --new-bindir $NEWBIN \
          "$@"
      '')
    ];
```
