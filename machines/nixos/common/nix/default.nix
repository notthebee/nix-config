{ lib, ... }:
{
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  nix.optimise.automatic = true;
  nix.optimise.dates = [ "weekly" ];

  nix.settings.experimental-features = lib.mkDefault [
    "nix-command"
    "flakes"
  ];

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
    };
  };
}
