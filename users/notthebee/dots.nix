{ inputs, lib, config, pkgs,  ... }: 
let
  home = {
    username = "notthebee";
    homeDirectory = "/home/notthebee";
    stateVersion = "23.11";
    };
in
{
  nixpkgs = {
    overlays = [
    ];
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
    };
  };

  home = home;

  imports = [
      ../../dots/zsh/default.nix
      ../../dots/nvim/default.nix
      ../../dots/neofetch/default.nix
      ./packages.nix
  ];

  programs.nix-index =
  {
    enable = true;
    enableZshIntegration = true;
  };


  programs.git = {
    enable = true;
    userName  = "Wolfgang";
    userEmail = "mail@weirdrescue.pw";
  };

  programs.home-manager.enable = true;

  systemd.user.startServices = "sd-switch";
  }
