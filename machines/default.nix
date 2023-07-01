{ config, pkgs, lib, ... }: {
  # load module config to top-level configuration

  system.stateVersion = "22.11";

  # Enable NetworkManager for wireless networking,
  # You can configure networking with "nmtui" command.
  networking.useDHCP = true;
  networking.networkmanager.enable = false;

  users.users = {
    root = {
      initialHashedPassword = "$6$tuU72Dtl7DhP1Hui$9pNeY3AkjcVNv90Nvo9EjTAaxizPaPMp0Cq0n4j89NvB3BWcya2hwNZ1i7OZ1neSLlQGGjXdg3fjn/X7aWIui0";
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
  environment.systemPackages = with pkgs; [
      iperf3
      exa
      neofetch
      tmux
      rsync
      iotop
      ncdu
      nmap
      jq
      ripgrep
    ];
}
