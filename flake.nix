{
  nixConfig = {
    trusted-substituters = [
      "https://cachix.cachix.org"
      "https://nixpkgs.cachix.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
      "nixpkgs.cachix.org-1:q91R6hxbwFvDqTSDKwDAV4T5PxqXGxswD8vhONFMeOE="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
  inputs = {
    flake-utils.url = "github:numtide/flake-utils?shallow=true";
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-25.05?shallow=true";
    };
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable?shallow=true";
    nixvim = {
      url = "github:nix-community/nixvim?shallow=true";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05?shallow=true";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-unstable = {
      url = "github:nix-community/home-manager/master?shallow=true";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    ryzen-undervolt = {
      url = "github:svenlange2/Ryzen-5800x3d-linux-undervolting/0f05965f9939259c27a428065fda5a6c0cbb9225?shallow=true";
      flake = false;
    };
    auto-aspm = {
      url = "github:notthebee/AutoASPM?shallow=true";
      flake = false;
    };
    agenix = {
      url = "github:ryantm/agenix?shallow=true";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    recyclarr-configs = {
      url = "github:recyclarr/config-templates?shallow=true";
      flake = false;
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin/master?shallow=true";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    adios-bot = {
      url = "github:notthebee/adiosbot?shallow=true";
      flake = false;
    };
    nix-index-database = {
      url = "github:Mic92/nix-index-database?shallow=true";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    secrets = {
      url = "git+ssh://git@github.com/notthebee/nix-private.git";
      flake = false;
    };
    jovian = {
      url = "github:Jovian-Experiments/Jovian-NixOS?shallow=true";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    alga = {
      url = "github:Tenzer/alga?shallow=true";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs =
    { flake-utils, nixpkgs, ... }@inputs:
    let
      helpers = import ./flakeHelpers.nix inputs;
      inherit (helpers) mkMerge mkNixos mkDarwin;
    in
    mkMerge [
      (flake-utils.lib.eachDefaultSystem (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          packages.default = pkgs.mkShell {
            packages = [
              pkgs.just
              pkgs.nixos-rebuild-ng
            ];
          };
        }
      ))
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
      (mkDarwin "meredith" inputs.nixpkgs-darwin
        [
          dots/tmux
          dots/kitty
        ]
        [ ]
      )
    ];
}
