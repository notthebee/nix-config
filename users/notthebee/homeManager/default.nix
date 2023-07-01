{ inputs, lib, config, pkgs,  ... }: {

  imports = [
  ./fish/default.nix
  ./nvim/default.nix
  ./git/default.nix
  ];
  nixpkgs = {
  overlays = [
  ];
  config = {
  allowUnfree = true;
  allowUnfreePredicate = (_: true);
  };
  };
  home = {
    username = "notthebee";
    homeDirectory = "/home/notthebee";
    };





programs.home-manager.enable = true;

systemd.user.startServices = "sd-switch";
home.stateVersion = "23.05";

}
