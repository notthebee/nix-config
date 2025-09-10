{ pkgs, ... }:

{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
    ../../users/notthebee
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  i18n.supportedLocales = [
    "en_US.UTF-8/UTF-8"
  ];
  i18n.defaultLocale = "en_US.UTF-8";

  security.sudo.wheelNeedsPassword = false;

  environment.systemPackages = with pkgs; [
    git
    rsync
    zsh
    neovim
    wget
    curl
    rxvt-unicode # for terminfo
  ];

  programs.zsh.enable = true;

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      LoginGraceTime = 0;
      PermitRootLogin = "no";
    };
  };

  system.stateVersion = "25.05";
}
