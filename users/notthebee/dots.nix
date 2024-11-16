{ ... }:
let
  home = {
    username = "notthebee";
    homeDirectory = "/home/notthebee";
    stateVersion = "23.11";
  };
in
{

  nixpkgs = {
    overlays = [ ];
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
    ./gitconfig.nix
  ];

  programs.nix-index = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.home-manager.enable = true;

  systemd.user.startServices = "sd-switch";
}
