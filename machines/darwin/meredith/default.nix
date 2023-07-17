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
    "logitech-options"
  ];

  masApps = {
    "microsoft-outlook" = 985367838;
  };
  };

  environment.shellInit = ''
    ulimit -n 2048
  '';

  environment.systemPackages = with pkgs; [
    yq
    git-lfs
    pre-commit
    ansible-lint
    ansible 
    (python310.withPackages(ps: with ps; [ 
                           setuptools
                           ansible
                           pip 
                           pre-commit
                           pyyaml
    ]))
  ];
     
}
