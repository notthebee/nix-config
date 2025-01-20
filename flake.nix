{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-24.11";
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-24.11-darwin";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-unstable = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    ryzen-undervolt = {
      url = "github:svenlange2/Ryzen-5800x3d-linux-undervolting/0f05965f9939259c27a428065fda5a6c0cbb9225";
      flake = false;
    };
    auto-aspm = {
      url = "github:notthebee/AutoASPM";
      flake = false;
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    recyclarr-configs = {
      url = "github:recyclarr/config-templates";
      flake = false;
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-24.11";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
    adios-bot = {
      url = "github:notthebee/adiosbot";
      flake = false;
    };
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    secrets = {
      url = "git+ssh://git@github.com/notthebee/nix-private.git";
      flake = false;
    };
    jovian = {
      url = "github:Jovian-Experiments/Jovian-NixOS";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    alga = {
      url = "github:Tenzer/alga";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    deploy-rs.url = "github:serokell/deploy-rs";

  };

  outputs =
    { ... }@inputs:
    let
      helpers = import ./flakeHelpers.nix inputs;
      inherit (helpers) mkMerge mkNixos mkDarwin;
    in
    mkMerge [
      (mkNixos "spencer" inputs.nixpkgs [
        ./modules/notthebe.ee
        ./homelab
        inputs.home-manager.nixosModules.home-manager
      ])
      (mkNixos "maya" inputs.nixpkgs-unstable [
        ./modules/ryzen-undervolt
        ./modules/lgtv
        inputs.jovian.nixosModules.default
        inputs.home-manager-unstable.nixosModules.home-manager
      ])
      (mkNixos "alison" inputs.nixpkgs [
        ./modules/zfs-root
        ./homelab
        inputs.home-manager.nixosModules.home-manager
      ])
      (mkNixos "emily" inputs.nixpkgs [
        ./modules/zfs-root
        ./modules/tailscale
        ./modules/adios-bot
        ./homelab
        inputs.home-manager.nixosModules.home-manager
      ])
      (mkNixos "aria" inputs.nixpkgs [
        ./modules/zfs-root
        ./modules/tailscale
        ./homelab
        inputs.home-manager.nixosModules.home-manager
      ])
      (mkDarwin "meredith" inputs.nixpkgs
        [
          dots/tmux
          dots/kitty
        ]
        [ ]
      )
    ];
}
