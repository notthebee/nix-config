{ inputs, lib, config, pkgs,  ... }: 
let
  home = {
    username = "beethenot";
    homeDirectory = "/Users/beethenot";
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
    userEmail = "";
  };

  programs.home-manager.enable = true;

  systemd.user.startServices = "sd-switch";
  }
