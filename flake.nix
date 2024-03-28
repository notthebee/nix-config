{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-23.11";
    nixvim = {
      url = "github:pta2002/nixvim/nixos-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
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

    nixpkgs-firefox-darwin = {
      url = "github:bandithedoge/nixpkgs-firefox-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur.url = "github:nix-community/nur";

    deploy-rs.url = "github:serokell/deploy-rs";
  };

  outputs = { self, 
              nixpkgs, 
              nix-darwin, 
              home-manager, 
              recyclarr-configs, 
              nixvim, 
              nix-index-database, 
              nixpkgs-firefox-darwin,
              agenix, 
              deploy-rs,
              nur,
              ... }@inputs:
    let 
      networksExternal = import ./machines/networksExternal.nix;
      networksLocal = import ./machines/networksLocal.nix;
    in {

    darwinConfigurations."meredith" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      specialArgs = {
        inherit inputs networksLocal networksExternal;
      };
      modules = [
        agenix.darwinModules.default
        ./machines/darwin
        ./machines/darwin/meredith
        ];
      };

    deploy.nodes = {
      emily = {
        hostname = (nixpkgs.lib.lists.findSingle (x: x.hostname == "emily") "none" "multiple" networksLocal.networks.lan.reservations).ip-address;
        profiles.system = {
          sshUser = "notthebee";
          user = "root";
          sshOpts = [ "-p" "69" ];
          remoteBuild = true;
          path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.emily;
        };
      };
    alison = {
        hostname = networksLocal.networks.lan.cidr;
        profiles.system = {
          sshUser = "notthebee";
          user = "root";
          sshOpts = [ "-p" "69" ];
          remoteBuild = true;
          path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.alison;
        };
      };
      spencer = {
        hostname = networksExternal.spencer.address;
        profiles.system = {
          sshUser = "notthebee";
          user = "root";
          sshOpts = [ "-p" "69" ];
          remoteBuild = true;
          path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.spencer;
        };
      };
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

            ./machines/nixos
            ./machines/nixos/alison
            ./secrets
            agenix.nixosModules.default

            ./services/traefik
            ./services/smarthome

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
            ./modules/appdata-backup

            # Import the machine config + secrets
            ./machines/nixos
            ./machines/nixos/emily
            ./secrets
            agenix.nixosModules.default

            # Services and applications
            ./services/invoiceninja
            ./services/timetagger
            ./services/paperless-ngx
            ./services/traefik
            ./services/deluge
            ./services/arr
            ./services/jellyfin
            ./services/vaultwarden
            ./services/monitoring
            ./services/kiwix
            ./services/pingvin-share
            ./services/homepage

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
