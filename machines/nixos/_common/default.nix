{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
{
  age.secrets.hashedUserPassword = {
    file = "${inputs.secrets}/hashedUserPassword.age";
  };

  system.stateVersion = "22.11";
  system.autoUpgrade = {
    enable = true;
    flake = "/etc/nixos\\?submodules=1";
    flags = [
      "--update-input"
      "nixpkgs"
      "-L"
    ];
    dates = "Sat *-*-* 06:00:00";
    randomizedDelaySec = "45min";
    allowReboot = true;
  };

  imports = [
    ./filesystems
    ./nix
    "${inputs.secrets}/networks.nix"
    ./secrets
  ];

  time.timeZone = "Europe/Berlin";

  users.users = {
    notthebee = {
      hashedPasswordFile = config.age.secrets.hashedUserPassword.path;
    };
    root = {
      initialHashedPassword = config.age.secrets.hashedUserPassword.path;
    };
  };

  services.openssh = {
    enable = lib.mkDefault true;
    settings = {
      PasswordAuthentication = lib.mkDefault false;
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
    smtpPasswordPath = config.age.secrets.smtpPassword.path;
  };

  security = {
    doas.enable = lib.mkDefault false;
    sudo = {
      enable = lib.mkDefault true;
      wheelNeedsPassword = lib.mkDefault false;
    };
  };

  homelab.motd.enable = true;

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
    inputs.agenix.packages."${system}".default
    lm_sensors
  ];

}
