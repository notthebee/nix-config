{ inputs, pkgs, lib, ... }:
{

  imports = [ ./system.nix ];
  homebrew = {
  casks = [
    "google-chrome"
    "slack"
    "zoom"
    "mattermost"
    "viscosity"
    "sequel-ace"
  ];

  masApps = {
    "microsoft-outlook" = 985367838;
  };
  };
}
