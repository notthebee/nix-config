# nix-config

Configuration files for my NixOS and nix-darwin machines.

Very much a work in progress.

### Installation
Adapted from [ne9z's "NixOS Root on ZFS"](https://openzfs.github.io/openzfs-docs/Getting%20Started/NixOS/Root%20on%20ZFS.html)

Elevate privileges, prepare the drive variable and the mountpoint
```bash
sudo su

DISK='/dev/disk/by-id/ata-Samsung_SSD_870_EVO_250GB_S6PENL0T902873K'
MNT=$(mktemp -d)
```

Enable flakes
```bash
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

Install git, jq and parted
```bash
if ! command -v git; then nix-env -f '<nixpkgs>' -iA git; fi
if ! command -v jq;  then nix-env -f '<nixpkgs>' -iA jq; fi
if ! command -v partprobe;  then nix-env -f '<nixpkgs>' -iA parted; fi
```

Partition the drives
```bash
partition_disk () {
 local disk="${1}"
 blkdiscard -f "${disk}" || true

 parted --script --align=optimal  "${disk}" -- \
 mklabel gpt \
 mkpart EFI 2MiB 1GiB \
 mkpart bpool 1GiB 5GiB \
 mkpart rpool 5GiB -1GiB \
 mkpart BIOS 1MiB 2MiB \
 set 1 esp on \
 set 4 bios_grub on \
 set 4 legacy_boot on

 partprobe "${disk}"
 udevadm settle
}

for i in ${DISK}; do
   partition_disk "${i}"
done
```

Create the boot pool
```bash
zpool create \
    -o compatibility=grub2 \
    -o ashift=12 \
    -o autotrim=on \
    -O acltype=posixacl \
    -O canmount=off \
    -O compression=lz4 \
    -O devices=off \
    -O normalization=formD \
    -O relatime=on \
    -O xattr=sa \
    -O mountpoint=/boot \
    -R "${MNT}" \
    bpool \
    $(for i in ${DISK}; do
       printf '%s ' "${i}-part2";
      done)
```

Create the root pool
```bash
zpool create \
    -o ashift=12 \
    -o autotrim=on \
    -R "${MNT}" \
    -O acltype=posixacl \
    -O canmount=off \
    -O compression=zstd \
    -O dnodesize=auto \
    -O normalization=formD \
    -O relatime=on \
    -O xattr=sa \
    -O mountpoint=/ \
    rpool \
   $(for i in ${DISK}; do
      printf '%s ' "${i}-part3";
     done)
```

Create root system container
```bash
zfs create \
 -o canmount=off \
 -o mountpoint=none \
rpool/nixos
```

Create the system datasets
```bash
zfs create -o mountpoint=legacy rpool/nixos/empty
mount -t zfs rpool/nixos/empty "${MNT}"/
zfs snapshot rpool/nixos/empty@start

zfs create -o mountpoint=legacy rpool/nixos/home
mkdir "${MNT}"/home
mount -t zfs rpool/nixos/home "${MNT}"/home

zfs create -o mountpoint=legacy rpool/nixos/var/log
zfs create -o mountpoint=none rpool/nixos/var/lib
zfs create -o mountpoint=legacy rpool/nixos/config
zfs create -o mountpoint=legacy rpool/nixos/persist
zfs create -o mountpoint=legacy rpool/nixos/nix

zfs create -s -V 50G rpool/docker
mkfs.ext4 /dev/zvol/rpool/docker
tune2fs -o journal_data_writeback /dev/zvol/rpool/docker 

zfs create -o mountpoint=none bpool/nixos
zfs create -o mountpoint=legacy bpool/nixos/root
mkdir "${MNT}"/boot
mount -t zfs bpool/nixos/root "${MNT}"/boot

mkdir -p "${MNT}"/var/log
mkdir -p "${MNT}"/etc/nixos
mkdir -p "${MNT}"/nix
mkdir -p "${MNT}"/persist

mount -t zfs rpool/nixos/var/log "${MNT}"/var/log
mount -t zfs rpool/nixos/config "${MNT}"/etc/nixos
mount -t zfs rpool/nixos/nix "${MNT}"/nix
mount -t zfs rpool/nixos/persist "${MNT}"/persist
```

Format and mount ESP
```bash
for i in ${DISK}; do
 mkfs.vfat -n EFI "${i}"-part1
 mkdir -p "${MNT}"/boot/efis/"${i##*/}"-part1
 mount -t vfat -o iocharset=iso8859-1 "${i}"-part1 "${MNT}"/boot/efis/"${i##*/}"-part1
done
```

Clone this repository
```bash
git clone https://github.com/notthebee/nix-config.git "${MNT}"/etc/nixos
```

Put the private key into place (required for secret management)
```bash
mkdir ${MNT}/home/notthebee/.ssh
exit
scp ~/.ssh/id_ed25519 nixos_installation_ip:/${MNT}/home/.ssh/id_ed25519
ssh nixos@installation-media
chmod 700 ${MNT}/home/notthebee/.ssh
chmod 600 $MNT}/home/notthebee/.ssh/id_ed25519
```

Install the system
```bash
nixos-install \
--root "${MNT}" \
--no-root-passwd \
--flake "git+file://${MNT}/etc/nixos#emily"
```

Unmount the filesystems
```bash
umount "${MNT}"/boot/efis/"${i##*/}"-part1
umount -Rl "${MNT}"
zpool export -a
```

Reboot
```bash
reboot
```
## meredith (Mac)
<img width="796" alt="Screenshot 2023-07-16 at 18 00 16" src="https://github.com/notthebee/nix-config/assets/30384331/65c3cdb2-9d56-497f-bf10-51aa1b65b488">

Managed using `nix-darwin` and `home-manager`. Impure packages and apps are managed by `homebrew` and `mas`
