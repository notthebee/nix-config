{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-envoy.url = "git+file:///Users/notthebee/Documents/Software/nixpkgs";
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
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
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
      (helpers.mkNixos "spencer" inputs.nixpkgs [
        ./modules/tg-notify
        ./modules/notthebe.ee
      ])
      (mkNixos "maya" inputs.nixpkgs-unstable [
        ./modules/ryzen-undervolt
        ./modules/lgtv
        inputs.jovian.nixosModules.default
        inputs.home-manager-unstable.nixosModules.home-manager
      ])
      (mkNixos "alison" inputs.nixpkgs [
        ./modules/motd
        ./modules/zfs-root
        ./modules/monitoring_stats
        ./modules/monitoring
        ./homelab/services/smarthome
        ./homelab/services/grafana
        inputs.home-manager.nixosModules.home-manager
      ])
      (mkNixos "emily" inputs.nixpkgs [
        ./modules/zfs-root
        ./modules/tg-notify
        ./modules/mover
        ./modules/motd
        ./modules/tailscale
        ./modules/monitoring_stats
        ./modules/adios-bot
        ./modules/duckdns
        ./homelab/services/sabnzbd
        ./homelab/services/vaultwarden
        ./homelab/services/nextcloud
        ./homelab
        inputs.home-manager.nixosModules.home-manager
      ])
      (mkNixos "aria" inputs.nixpkgs [
        ./modules/zfs-root
        ./modules/tg-notify
        ./modules/motd
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
