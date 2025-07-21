# nix-config

Configuration files for my NixOS and nix-darwin machines.

Very much a work in progress.

## Services

## alison

| Icon                                                                                                                                                     | Service        | Description              | Category   |
| -------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------- | ------------------------ | ---------- |
| <img src='https://raw.githubusercontent.com/homarr-labs/dashboard-icons/refs/heads/main/svg/home-assistant.svg' alt='Home Assistant' width=32 height=32> | Home Assistant | Home automation platform | Smart Home |
| <img src='https://raw.githubusercontent.com/homarr-labs/dashboard-icons/refs/heads/main/png/raspberrymatic.png' alt='RaspberryMatic' width=32 height=32> | RaspberryMatic | Homematic IP CCU         | Smart Home |
| <img src='https://raw.githubusercontent.com/homarr-labs/dashboard-icons/refs/heads/main/svg/uptime-kuma.svg' alt='Uptime Kuma' width=32 height=32>       | Uptime Kuma    | Service monitoring tool  | Services   |

## aria

| Icon                                                                                                                                     | Service | Description                                     | Category |
| ---------------------------------------------------------------------------------------------------------------------------------------- | ------- | ----------------------------------------------- | -------- |
| <img src='https://raw.githubusercontent.com/homarr-labs/dashboard-icons/refs/heads/main/svg/immich.svg' alt='Immich' width=32 height=32> | Immich  | Self-hosted photo and video management solution | Media    |

## emily

| Icon                                                                                                                                                     | Service        | Description                                     | Category  |
| -------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------- | ----------------------------------------------- | --------- |
| <img src='https://raw.githubusercontent.com/homarr-labs/dashboard-icons/refs/heads/main/svg/audiobookshelf.svg' alt='Audiobookshelf' width=32 height=32> | Audiobookshelf | Audiobook and podcast player                    | Media     |
| <img src='https://raw.githubusercontent.com/homarr-labs/dashboard-icons/refs/heads/main/svg/bazarr.svg' alt='Bazarr' width=32 height=32>                 | Bazarr         | Subtitle manager                                | Arr       |
| <img src='https://raw.githubusercontent.com/homarr-labs/dashboard-icons/refs/heads/main/svg/deluge.svg' alt='Deluge' width=32 height=32>                 | Deluge         | Torrent client                                  | Downloads |
| <img src='https://raw.githubusercontent.com/homarr-labs/dashboard-icons/refs/heads/main/svg/immich.svg' alt='Immich' width=32 height=32>                 | Immich         | Self-hosted photo and video management solution | Media     |
| <img src='https://raw.githubusercontent.com/homarr-labs/dashboard-icons/refs/heads/main/svg/jellyfin.svg' alt='Jellyfin' width=32 height=32>             | Jellyfin       | The Free Software Media System                  | Media     |
| <img src='https://raw.githubusercontent.com/homarr-labs/dashboard-icons/refs/heads/main/svg/jellyseerr.svg' alt='Jellyseerr' width=32 height=32>         | Jellyseerr     | Media request and discovery manager             | Arr       |
| <img src='https://raw.githubusercontent.com/homarr-labs/dashboard-icons/refs/heads/main/svg/keycloak.svg' alt='Keycloak' width=32 height=32>             | Keycloak       | Open Source Identity and Access Management      | Services  |
| <img src='https://raw.githubusercontent.com/homarr-labs/dashboard-icons/refs/heads/main/png/microbin.png' alt='Microbin' width=32 height=32>             | Microbin       | A minimal pastebin                              | Services  |
| <img src='https://raw.githubusercontent.com/homarr-labs/dashboard-icons/refs/heads/main/svg/miniflux.svg' alt='Miniflux' width=32 height=32>             | Miniflux       | Minimalist and opinionated feed reader          | Services  |
| <img src='https://raw.githubusercontent.com/homarr-labs/dashboard-icons/refs/heads/main/svg/owncloud.svg' alt='OCIS' width=32 height=32>                 | OCIS           | Enterprise File Storage and Collaboration       | Services  |
| <img src='https://raw.githubusercontent.com/homarr-labs/dashboard-icons/refs/heads/main/svg/paperless.svg' alt='Paperless-ngx' width=32 height=32>       | Paperless-ngx  | Document management system                      | Services  |
| <img src='https://raw.githubusercontent.com/homarr-labs/dashboard-icons/refs/heads/main/svg/prowlarr.svg' alt='Prowlarr' width=32 height=32>             | Prowlarr       | PVR indexer                                     | Arr       |
| <img src='https://raw.githubusercontent.com/homarr-labs/dashboard-icons/refs/heads/main/svg/radarr.svg' alt='Radarr' width=32 height=32>                 | Radarr         | Movie collection manager                        | Arr       |
| <img src='https://raw.githubusercontent.com/homarr-labs/dashboard-icons/refs/heads/main/svg/radicale.svg' alt='Radicale' width=32 height=32>             | Radicale       | Free and Open-Source CalDAV and CardDAV Server  | Services  |
| <img src='https://raw.githubusercontent.com/homarr-labs/dashboard-icons/refs/heads/main/svg/sabnzbd.svg' alt='SABnzbd' width=32 height=32>               | SABnzbd        | The free and easy binary newsreader             | Downloads |
| <img src='https://raw.githubusercontent.com/homarr-labs/dashboard-icons/refs/heads/main/svg/sonarr.svg' alt='Sonarr' width=32 height=32>                 | Sonarr         | TV show collection manager                      | Arr       |
| <img src='https://raw.githubusercontent.com/homarr-labs/dashboard-icons/refs/heads/main/svg/bitwarden.svg' alt='Vaultwarden' width=32 height=32>         | Vaultwarden    | Password manager                                | Services  |

## Installation runbook (NixOS)

Create a root password using the TTY

```bash
sudo su
passwd
```

From your host, copy the public SSH key to the server

```bash
export NIXOS_HOST=192.168.2.xxx
ssh-add ~/.ssh/notthebee
ssh-copy-id -i ~/.ssh/notthebee root@$NIXOS_HOST
```

SSH into the host with agent forwarding enabled (for the secrets repo access)

```bash
ssh -A root@$NIXOS_HOST
```

Enable flakes

```bash
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

Partition and mount the drives using [disko](https://github.com/nix-community/disko)

```bash
DISK='/dev/disk/by-id/ata-Samsung_SSD_870_EVO_250GB_S6PENL0T902873K'
DISK2='/dev/disk/by-id/ata-Samsung_SSD_870_EVO_250GB_S6PE58S586SAER'

curl https://raw.githubusercontent.com/notthebee/nix-config/main/disko/zfs-root/default.nix \
    -o /tmp/disko.nix
sed -i "s|to-be-filled-during-installation|$DISK|" /tmp/disko.nix
nix --experimental-features "nix-command flakes" run github:nix-community/disko \
    -- -m destroy,format,mount /tmp/disko.nix
```

Install git

```bash
nix-env -f '<nixpkgs>' -iA git
```

Clone this repository

```bash
mkdir -p /mnt/etc/nixos
git clone https://github.com/notthebee/nix-config.git /mnt/etc/nixos
```

Put the private key into place (required for secret management)

```bash
mkdir -p /mnt/home/notthebee/.ssh
exit
scp ~/.ssh/notthebee root@$NIXOS_HOST:/mnt/home/notthebee/.ssh
ssh root@$NIXOS_HOST
chmod 700 /mnt/home/notthebee/.ssh
chmod 600 /mnt/home/notthebee/.ssh/*
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
umount "/mnt/boot/efis/*"
umount -Rl "/mnt"
zpool export -a
```

Reboot

```bash
reboot
```
