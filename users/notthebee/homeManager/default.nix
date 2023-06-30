{ inputs, lib, config, pkgs,  ... }: {

  imports = [
  ./fish/default.nix
  inputs.nixvim.homeManagerModules.nixvim
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
programs.nixvim.enable = true;

systemd.user.startServices = "sd-switch";
home.stateVersion = "23.05";

}
