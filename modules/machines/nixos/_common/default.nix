{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
{

  programs.ssh = {
    knownHosts = {
      "github.com".publicKey =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
    };
    extraConfig = ''
      Host github.com
        User git
        IdentityFile /persist/ssh/ssh_host_ed25519_key
        IdentitiesOnly yes
    '';
  };

  system.stateVersion = "22.11";

  systemd.services.nixos-upgrade.preStart = ''
    cd /etc/nixos
    chown -R root:root .
    git reset --hard HEAD
    git pull
  '';
  system.autoUpgrade = {
    enable = true;
    flake = "/etc/nixos#${config.networking.hostName}";
    flags = [
      "-L"
      "--accept-flake-config"
    ];
    dates = "Sat *-*-* 02:30:00";
    allowReboot = true;
  };

  imports = [
    ./filesystems
    ./nix
    ./monitoring
  ];

  time.timeZone = "Europe/Berlin";

  # Plaintext passwords
  users.users = {
    notthebee = {
      initialPassword = "Felix";
    };
    root = {
      initialPassword = "Felix!50";
    };
  };

  services.openssh = {
    enable = lib.mkDefault true;
    settings = {
      PasswordAuthentication = true;
      LoginGraceTime = 0;
      PermitRootLogin = "no";
    };
    ports = [ 69 ];
    hostKeys = [
      {
        path = "/persist/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
      {
        path = "/persist/ssh/ssh_host_rsa_key";
        type = "rsa";
        bits = 4096;
      }
    ];
  };

  programs.git.enable = true;
  programs.mosh.enable = true;
  programs.htop.enable = true;
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
  };

  email = {
    enable = true;
    fromAddress = "moe@notthebe.ee";
    toAddress = "server_announcements@mailbox.org";
    smtpServer = "email-smtp.eu-west-1.amazonaws.com";
    smtpUsername = "AKIAYYXVLL34J7LSXFZF";
    smtpPasswordPath = "/persist/secrets/smtpPassword";
  };

  security = {
    doas.enable = lib.mkDefault false;
    sudo = {
      enable = lib.mkDefault true;
      wheelNeedsPassword = lib.mkDefault false;
    };
  };

  homelab.motd.enable = true;

  # Network configuration
  homelab.networks = {
    local.lan = {
      id = 1;
      cidr.v4 = "192.168.2.1";
      interface = "lan1";
      trusted = true;
      reservations = {
        emily = { MACAddress = "68:05:ca:39:92:d9"; Address = "192.168.2.199"; };
      };
    };
  };

  environment.systemPackages = with pkgs; [
    wget
    iperf3
    eza
    fastfetch
    tmux
    rsync
    iotop
    ncdu
    nmap
    jq
    ripgrep
    lm_sensors
  ];

}
