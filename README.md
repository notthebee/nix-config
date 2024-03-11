# nix-config

Configuration files for my NixOS and nix-darwin machines.

Very much a work in progress.

## Installation runbook (NixOS)

Create a root password using the TTY
```bash
sudo su
passwd
```

From your host, copy the public SSH key to the server
```bash
ssh-add ~/.ssh/notthebee
ssh-copy-id -i ~/.ssh/notthebee root@<NIXOS-IP>
ssh root@<NIXOS-IP>
```

Enable flakes
```bash
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

Partition and mount the drives using [disko](https://github.com/nix-community/disko)
```bash
DISK='/dev/disk/by-id/ata-Samsung_SSD_870_EVO_250GB_S6PENL0T902873K'

curl https://raw.githubusercontent.com/notthebee/nix-config/main/disko/zfs-root/default.nix \
    -o /tmp/disko.nix
sed -i "s|to-be-filled-during-installation|$DISK|" /tmp/disko.nix
nix --experimental-features "nix-command flakes" run github:nix-community/disko \
    -- --mode disko /tmp/disko.nix
```

Install git and git-crypt
```bash
nix-env -f '<nixpkgs>' -iA git
nix-env -f '<nixpkgs>' -iA git-crypt
```

Clone this repository
```bash
mkdir -p /mnt/etc/nixos
git clone https://github.com/notthebee/nix-config.git /mnt/etc/nixos
```

Put the private and GPG key into place (required for secret management)
```bash
mkdir -p /mnt/home/notthebee/.ssh
exit
scp ~/.ssh/id_ed25519 root@<NIXOS-IP>:/mnt/home/notthebee/.ssh
scp ~/.ssh/git-crypt-nix root@<NIXOS-IP>:/mnt/home/notthebee/.ssh
ssh root@<NIXOS-IP>
chmod 700 /mnt/home/notthebee/.ssh
chmod 600 /mnt/home/notthebee/.ssh/*
```

Unlock the git-crypt vault
```bash
cd /mnt/etc/nixos
git-crypt unlock /mnt/home/notthebee/.ssh/git-crypt-nix
```

Install the system
```bash
nixos-install \
--root "/mnt" \
--no-root-passwd \
--flake "git+file:///mnt/etc/nixos#hostname" # alison, emily, etc.
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
