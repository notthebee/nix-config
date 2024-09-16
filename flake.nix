{
  inputs = {
    secrets = {
      url = "git+file:secrets";
      flake = false;
    };
    nixpkgs.url = "github:nixos/nixpkgs/release-24.05";
    nixvim = {
      url = "github:nix-community/nixvim/nixos-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
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

    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur.url = "github:nix-community/nur";

  };

  outputs =
    { self
    , nixpkgs
    , nix-darwin
    , home-manager
    , recyclarr-configs
    , nixvim
    , nix-index-database
    , agenix
    , nur
    , ...
    }@inputs:
    let
      networksExternal = import ./machines/networksExternal.nix;
      networksLocal = import ./machines/networksLocal.nix;
    in
    {

      darwinConfigurations."meredith" = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = {
          inherit inputs networksLocal networksExternal;
        };
        modules = [
          agenix.darwinModules.default
          ./machines/darwin
          ./machines/darwin/meredith
          ./modules/deploy-nix
        ];
      };

      nixosConfigurations = {
        spencer = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs networksLocal networksExternal;
            vars = import ./machines/nixos/vars.nix;
          };
          modules = [
            # Base configuration and modules
            ./modules/email
            ./modules/tg-notify
            ./modules/notthebe.ee

            # Import the machine config + secrets
            ./machines/nixos
            ./machines/nixos/spencer
            ./secrets
            agenix.nixosModules.default

            # User-specific configurations
            ./users/notthebee
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = false; # makes hm use nixos's pkgs value
              home-manager.extraSpecialArgs = { inherit inputs networksLocal networksExternal; }; # allows access to flake inputs in hm modules
              home-manager.users.notthebee.imports = [
                agenix.homeManagerModules.default
                nix-index-database.hmModules.nix-index
                ./users/notthebee/dots.nix
              ];
              home-manager.backupFileExtension = "bak";
            }
          ];
        };

        alison = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs networksLocal networksExternal;
            vars = import ./machines/nixos/vars.nix;
          };
          modules = [
            # Base configuration and modules
            ./modules/tg-notify
            ./modules/router
            ./modules/podman
            ./modules/motd
            ./modules/zfs-root
            ./modules/email
            ./modules/duckdns
            ./modules/monitoring_stats
            ./modules/monitoring

            ./machines/nixos
            ./machines/nixos/alison
            ./secrets
            agenix.nixosModules.default

            ./containers/traefik
            ./containers/smarthome
            ./containers/grafana

            # User-specific configurations
            ./users/notthebee
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = false; # makes hm use nixos's pkgs value
              home-manager.extraSpecialArgs = { inherit inputs networksLocal networksExternal; };
              home-manager.users.notthebee.imports = [
                agenix.homeManagerModules.default
                nix-index-database.hmModules.nix-index
                ./users/notthebee/dots.nix
              ];
              home-manager.backupFileExtension = "bak";
            }
          ];
        };

        emily = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs networksLocal networksExternal;
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

            # Import the machine config + secrets
            ./machines/nixos
            ./machines/nixos/emily
            ./secrets
            agenix.nixosModules.default

            # Services and applications
            #./containers/invoiceninja
            #./containers/timetagger
            ./containers/paperless-ngx
            ./containers/traefik
            ./containers/deluge
            ./containers/arr
            ./containers/jellyfin
            ./containers/vaultwarden
            ./containers/pingvin-share
            ./containers/homepage

            # User-specific configurations
            ./users/notthebee
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = false;
              home-manager.extraSpecialArgs = { inherit inputs networksLocal networksExternal; };
              home-manager.users.notthebee.imports = [
                agenix.homeManagerModules.default
                nix-index-database.hmModules.nix-index
                ./users/notthebee/dots.nix
              ];
              home-manager.backupFileExtension = "bak";
            }
          ];
        };
        aria = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs networksLocal networksExternal;
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
            ./secrets
            agenix.nixosModules.default

            # Services and applications
            ./containers/traefik
            ./containers/immich

            # User-specific configurations
            ./users/notthebee
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = false;
              home-manager.extraSpecialArgs = { inherit inputs networksLocal networksExternal; };
              home-manager.users.notthebee.imports = [
                agenix.homeManagerModules.default
                nix-index-database.hmModules.nix-index
                ./users/notthebee/dots.nix
              ];
              home-manager.backupFileExtension = "bak";
            }
          ];
        };

      };
    };
}
