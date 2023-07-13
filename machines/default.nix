{ inputs, config, pkgs, lib, ... }: 
{
  # load module config to top-level configuration

  system.stateVersion = "22.11";

  # Enable NetworkManager for wireless networking,
  # You can configure networking with "nmtui" command.
  networking.useDHCP = true;
  networking.networkmanager.enable = false;

  users.users = {
    root = {
      initialHashedPassword = config.age.secrets.hashedUserPassword.path;
      openssh.authorizedKeys.keys = [ "sshKey_placeholder" ];
    };
  };
  services.openssh = {
    enable = lib.mkDefault true;
    settings = {
    PasswordAuthentication = lib.mkDefault false; 
    PermitRootLogin = "no";
    };
    ports = [ 69 ];
  };

  nix.settings.experimental-features = lib.mkDefault [ "nix-command" "flakes" ];

  programs.git.enable = true;
  programs.mosh.enable = true;
  programs.htop.enable = true;

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
  };

  security = {
    doas.enable = lib.mkDefault false;
    sudo = {
      enable = lib.mkDefault true;
      wheelNeedsPassword = lib.mkDefault false;
    };
  };
  
  systemd.services.glances = {
    after = [ "network.target" ];
    script = "${pkgs.glances}/bin/glances -w";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Restart = "on-abort";
      RemainAfterExit = "yes";
    };
  };

  networking.firewall.allowedTCPPorts = [ 
  61208 # glances
  5201 # iperf3 
  ];

  networking.firewall.allowPing = true;

  system.autoUpgrade.enable = true; 

  environment.systemPackages = with pkgs; [
    pciutils
    cpufrequtils
    glances
    iperf3
    exa
    neofetch
    tmux
    rsync
    iotop
    hdparm
    hd-idle
    hddtemp
    smartmontools
    ncdu
    nmap
    jq
    ripgrep
    sqlite
    inputs.agenix.packages."${system}".default 
  ];
}
