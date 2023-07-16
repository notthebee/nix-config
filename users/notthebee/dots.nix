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
      ../../dots/fish/default.nix
      ../../dots/nvim/default.nix
      ../../dots/neofetch/default.nix
      ./packages.nix
  ];

  programs.nix-index =
  {
    enable = true;
    enableFishIntegration = true;
  };


  programs.git = {
    enable = true;
    userName  = "Wolfgang";
    userEmail = "mail@weirdrescue.pw";
  };

  programs.home-manager.enable = true;

  systemd.user.startServices = "sd-switch";
  }
