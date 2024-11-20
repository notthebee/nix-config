{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-24.05";
    nixpkgs-fix-ghostscript.url = "github:nixos/nixpkgs/aecd17c0dbd112d6df343827d9324f071ef9c502";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
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
      inputs.nixpkgs.follows = "nixpkgs-fix-ghostscript";
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
    nur.url = "github:nix-community/nur";

  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      nix-darwin,
      home-manager,
      alga,
      home-manager-unstable,
      recyclarr-configs,
      adios-bot,
      ryzen-undervolt,
      nixvim,
      jovian,
      deploy-rs,
      nix-index-database,
      agenix,
      nur,
      ...
    }@inputs:
    let
      homeManagerCfg = userPackages: extraImports: {
        home-manager.useGlobalPkgs = false;
        home-manager.extraSpecialArgs = {
          inherit inputs;
        };
        home-manager.users.notthebee.imports = [
          agenix.homeManagerModules.default
          nix-index-database.hmModules.nix-index
          ./users/notthebee/dots.nix
        ];
        home-manager.backupFileExtension = "bak";
        home-manager.useUserPackages = userPackages;
      };
      mkDarwin = machineHostname: extraHmModules: extraModules: {
        darwinConfigurations.${machineHostname} = nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = {
            inherit inputs;
          };
          modules = [
            "${inputs.secrets}/default.nix"
            agenix.darwinModules.default
            ./machines/darwin
            ./machines/darwin/${machineHostname}
            home-manager.darwinModules.home-manager
            (nixpkgs.lib.attrsets.recursiveUpdate (homeManagerCfg true extraHmModules) {
              home-manager.users.notthebee.home.homeDirectory = nixpkgs.lib.mkForce "/Users/notthebee";
            })
          ];
        };
      };
      mkNixos = machineHostname: nixpkgsVersion: extraModules: {
        deploy.nodes.${machineHostname} = {
          hostname = machineHostname;
          profiles.system = {
            user = "root";
            sshUser = "notthebee";
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.${machineHostname};
          };
        };
        nixosConfigurations.${machineHostname} = nixpkgsVersion.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
            vars = import ./machines/nixos/vars.nix;
          };
          modules = [
            ./homelab
            ./machines/nixos
            ./machines/nixos/${machineHostname}
            ./modules/email
            "${inputs.secrets}/default.nix"
            agenix.nixosModules.default
            ./users/notthebee
            (homeManagerCfg false)
            home-manager.darwinModules.home-manager
          ] ++ extraModules;
        };
      };
      mkMerge = nixpkgs.lib.lists.foldl' (a: b: nixpkgs.lib.attrsets.recursiveUpdate a b) { };
    in
    mkMerge [
      (mkNixos "spencer" nixpkgs [
        ./modules/tg-notify
        ./modules/notthebe.ee
      ])
      (mkNixos "maya" nixpkgs-unstable [
        ./modules/ryzen-undervolt
        ./modules/lgtv
        jovian.nixosModules.default
        home-manager-unstable.nixosModules.home-manager
      ])
      (mkNixos "alison" nixpkgs [
        ./modules/motd
        ./modules/zfs-root
        ./modules/monitoring_stats
        ./modules/monitoring
        ./homelab/services/smarthome
        ./homelab/services/grafana
        home-manager.nixosModules.home-manager
      ])
      (mkNixos "emily" nixpkgs [
        ./modules/aspm-tuning
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
        ./homelab/services/pingvin-share
        ./homelab
        home-manager.nixosModules.home-manager
      ])
      (mkNixos "aria" nixpkgs [
        ./modules/aspm-tuning
        ./modules/zfs-root
        ./modules/tg-notify
        ./modules/motd
        ./modules/tailscale
        ./homelab
        home-manager.nixosModules.home-manager
      ])
      (mkDarwin "meredith" [
        dots/tmux
        dots/kitty
      ] [ ])
    ];
}
