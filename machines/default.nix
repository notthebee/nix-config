{ inputs, config, pkgs, lib, ... }: 
let 
  mergerfs_root = "/mnt/user";
  cache_root = "/mnt/cache";
  docker_root = "/var/opt/docker";
in
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
      sqlite
      inputs.agenix.packages."${system}".default 
    ];
}
