{ inputs, lib, config, pkgs,  ... }: 
let
  home = {
    username = "notthebee";
    homeDirectory = "/home/notthebee";
    stateVersion = "23.05";
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
      ./fish/default.nix
      ./nvim/default.nix
      ./git/default.nix
  ];

  programs.home-manager.enable = true;

  systemd.user.startServices = "sd-switch";
  }
