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
      nixosHosts = [
        "spencer"
        "aria"
        "alison"
        "maya"
        "emily"
      ];
      darwinHosts = [ "meredith" ];
      homeManagerCfg = {
        home-manager.useGlobalPkgs = false; # makes hm use nixos's pkgs value
        home-manager.extraSpecialArgs = {
          inherit inputs;
        }; # allows access to flake inputs in hm modules
        home-manager.users.notthebee.imports = [
          agenix.homeManagerModules.default
          nix-index-database.hmModules.nix-index
          ./users/notthebee/dots.nix
        ];
        home-manager.backupFileExtension = "bak";
      };
    in
    {
      deploy.nodes =
        let
          nixosConfigurations = self.nixosConfigurations;
          deployProfile = hostname: {
            hostname = hostname;
            profiles.system = {
              user = "root";
              sshUser = "notthebee";
              path = deploy-rs.lib.x86_64-linux.activate.nixos nixosConfigurations.${hostname};
            };
          };
        in
        nixpkgs.lib.attrsets.genAttrs nixosHosts (hostname: deployProfile hostname);

      darwinConfigurations."meredith" = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = {
          inherit inputs;
        };
        modules = [
          "${inputs.secrets}/default.nix"
          agenix.darwinModules.default
          ./machines/darwin
          ./machines/darwin/meredith
        ];
      };
      nixosConfigurations = {
        maya = nixpkgs-unstable.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;

          };
          modules = [
            ./machines/nixos
            ./machines/nixos/maya
            ./modules/ryzen-undervolt
            ./modules/lgtv
            ./modules/email
            "${inputs.secrets}/default.nix"
            agenix.nixosModules.default
            jovian.nixosModules.default
            home-manager-unstable.nixosModules.home-manager
            ./users/notthebee
            homeManagerCfg
          ];
        };
        spencer = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
            vars = import ./machines/nixos/vars.nix;
          };
          modules = [
            # Base configuration and modules
            ./modules/email
            ./modules/tg-notify
            ./modules/notthebe.ee
            ./homelab

            # Import the machine config + secrets
            ./machines/nixos
            ./machines/nixos/spencer
            "${inputs.secrets}/default.nix"
            agenix.nixosModules.default

            # User-specific configurations
            ./users/notthebee
            home-manager.nixosModules.home-manager
            homeManagerCfg
          ];
        };
        alison = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
            vars = import ./machines/nixos/vars.nix;
          };
          modules = [
            # Base configuration and modules
            ./modules/tg-notify
            ./modules/podman
            ./modules/motd
            ./modules/zfs-root
            ./modules/email
            ./modules/monitoring_stats
            ./modules/monitoring

            ./machines/nixos
            ./machines/nixos/alison
            "${inputs.secrets}/default.nix"
            agenix.nixosModules.default

            ./homelab
            ./homelab/smarthome
            ./homelab/grafana

            # User-specific configurations
            ./users/notthebee
            home-manager.nixosModules.home-manager
            homeManagerCfg
          ];
        };

        emily = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
            vars = import ./machines/nixos/vars.nix;
          };
          modules = [
            # Base configuration and modules
            ./modules/aspm-tuning
            ./modules/zfs-root
            ./modules/email
            ./modules/tg-notify
            ./modules/podman
            ./modules/mover
            ./modules/motd
            ./modules/tailscale
            ./modules/monitoring_stats
            ./modules/adios-bot
            ./modules/duckdns

            # Import the machine config + secrets
            ./machines/nixos
            ./machines/nixos/emily
            "${inputs.secrets}/default.nix"
            agenix.nixosModules.default

            # Services and applications
            #./homelab/invoiceninja
            #./homelab/timetagger
            ./homelab/sabnzbd
            ./homelab/vaultwarden
            ./homelab/pingvin-share
            ./homelab

            # User-specific configurations
            ./users/notthebee
            home-manager.nixosModules.home-manager
            homeManagerCfg
          ];
        };
        aria = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
            vars = import ./machines/nixos/aria/vars.nix;
          };
          modules = [
            # Base configuration and modules
            ./modules/aspm-tuning
            ./modules/zfs-root
            ./modules/email
            ./modules/tg-notify
            ./modules/podman
            ./modules/motd
            ./modules/tailscale

            # Import the machine config + secrets
            ./machines/nixos
            ./machines/nixos/aria
            "${inputs.secrets}/default.nix"
            agenix.nixosModules.default

            # Services and applications
            ./homelab

            # User-specific configurations
            ./users/notthebee
            home-manager.nixosModules.home-manager
            homeManagerCfg
          ];
        };
      };
    };
}
