# nix-config

Configuration files for my NixOS and nix-darwin machines.

Very much a work in progress.

### Installation

Create a root password in the TTY, and then ssh into the server
```bash
sudo su
passwd
exit
ssh root@<NIXOS-IP>
```

```bash
Elevate privileges and set the boot drive variable
```bash
sudo su
DISK='/dev/disk/by-id/ata-Samsung_SSD_870_EVO_250GB_S6PENL0T902873K'
```

Enable flakes
```bash
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

Install git and git-crypt
```bash
nix-env -f '<nixpkgs>' -iA git
nix-env -f '<nixpkgs>' -iA git-crypt
```

Clone this repository
```bash
mkdir -p /tmp/nixos
git clone https://github.com/notthebee/nix-config.git /tmp/nixos
```

Partition and mount the drives using [disko](https://github.com/nix-community/disko)
```bash
nix --experimental-features "nix-command flakes" run github:nix-community/disko \
    -- --mode disko /tmp/nixos/disko/zfs-root/default.nix
```

Put the private and GPG key into place (required for secret management)
```bash
mkdir -p /mnt/home/notthebee/.ssh
exit
scp ~/.ssh/id_ed25519 nixos_installation_ip:/mnt/home/notthebee/.ssh/id_ed25519
scp ~/.ssh/git-crypt-nix nixos_installation_ip:/mnt/home/notthebee/.ssh/git-crypt-nix
ssh root@installation-media
chmod 700 ${MNT}/home/notthebee/.ssh
chmod 600 $MNT}/home/notthebee/.ssh/*
```

Install the system
```bash
nixos-install \
--root "/mnt" \
--no-root-passwd \
--flake "git+file://${MNT}/etc/nixos#emily"
```

Unmount the filesystems
```bash
umount "/mnt/boot/esp"
umount -Rl "/mnt"
zpool export -a
```

Reboot
```bash
reboot
```
