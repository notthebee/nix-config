{
  inputs,
  pkgs,
  lib,
  ...
}:
{
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
    };
  };
  imports = [ <home-manager/nix-darwin> ];
  home-manager = {
    useGlobalPkgs = false; # makes hm use nixos's pkgs value
    extraSpecialArgs = {
      inherit inputs;
    }; # allows access to flake inputs in hm modules
    users.notthebee =
      { config, pkgs, ... }:
      {
        home.homeDirectory = lib.mkForce "/Users/notthebee";

        imports = [
          inputs.nix-index-database.hmModules.nix-index
          inputs.agenix.homeManagerModules.default
          ../../users/notthebee/dots.nix
          ../../users/notthebee/age.nix
          ../../dots/tmux
          ../../dots/kitty
        ];
      };

    backupFileExtension = "bak";
    useUserPackages = true;
  };

  services.karabiner-elements.enable = true;
  nix = {
    linux-builder.enable = true;
    settings = {
      max-jobs = "auto";
      trusted-users = [
        "root"
        "notthebee"
        "@admin"
      ];
    };
  };
}
