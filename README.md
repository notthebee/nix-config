# nix-config

Configuration files for my NixOS and nix-darwin machines.

Very much a work in progress.

## Services

> This section is generated automatically from the Nix configuration using GitHub Actions and [this cursed Nix script](bin/generateServicesTable.nix)

<!-- BEGIN SERVICE LIST -->
### alison
|Icon|Name|Category|Description|
|---|---|---|---|
|<img src='https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/home-assistant.svg' width=32 height=32>|Home Assistant|Home automation platform|Smart Home|
|<img src='https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/raspberrymatic.png' width=32 height=32>|RaspberryMatic|Homematic IP CCU|Smart Home|
|<img src='https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/uptime-kuma.svg' width=32 height=32>|Uptime Kuma|Service monitoring tool|Services|


### aria
|Icon|Name|Category|Description|
|---|---|---|---|
|<img src='https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/immich.svg' width=32 height=32>|Immich|Self-hosted photo and video management solution|Media|


### emily
|Icon|Name|Category|Description|
|---|---|---|---|
|<img src='https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/audiobookshelf.svg' width=32 height=32>|Audiobookshelf|Audiobook and podcast player|Media|
|<img src='https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/bazarr.svg' width=32 height=32>|Bazarr|Subtitle manager|Arr|
|<img src='https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/deluge.svg' width=32 height=32>|Deluge|Torrent client|Downloads|
|<img src='https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/immich.svg' width=32 height=32>|Immich|Self-hosted photo and video management solution|Media|
|<img src='https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/jellyfin.svg' width=32 height=32>|Jellyfin|The Free Software Media System|Media|
|<img src='https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/jellyseerr.svg' width=32 height=32>|Jellyseerr|Media request and discovery manager|Arr|
|<img src='https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/keycloak.svg' width=32 height=32>|Keycloak|Open Source Identity and Access Management|Services|
|<img src='https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/microbin.png' width=32 height=32>|Microbin|A minimal pastebin|Services|
|<img src='https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/miniflux-light.svg' width=32 height=32>|Miniflux|Minimalist and opinionated feed reader|Services|
|<img src='https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/owncloud.svg' width=32 height=32>|OCIS|Enterprise File Storage and Collaboration|Services|
|<img src='https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/paperless.svg' width=32 height=32>|Paperless-ngx|Document management system|Services|
|<img src='https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/prowlarr.svg' width=32 height=32>|Prowlarr|PVR indexer|Arr|
|<img src='https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/radarr.svg' width=32 height=32>|Radarr|Movie collection manager|Arr|
|<img src='https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/radicale.svg' width=32 height=32>|Radicale|Free and Open-Source CalDAV and CardDAV Server|Services|
|<img src='https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/sabnzbd.svg' width=32 height=32>|SABnzbd|The free and easy binary newsreader|Downloads|
|<img src='https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/sonarr.svg' width=32 height=32>|Sonarr|TV show collection manager|Arr|
|<img src='https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/bitwarden.svg' width=32 height=32>|Vaultwarden|Password manager|Services|


<!-- END SERVICE LIST -->

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
