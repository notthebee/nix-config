{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    nixvim.url = "github:pta2002/nixvim/nixos-23.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
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
    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, recyclarr-configs, nixvim, nix-index-database, agenix, ... }@inputs: {

    nixosConfigurations = {
      emily = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { 
        inherit inputs; 
        vars = import ./machines/emily/vars.nix;
        };
        modules = [ 
          # Base configuration and modules
          ./modules/aspm-tuning
          ./modules/zfs-root
          ./modules/email
          ./modules/tg-notify
          ./modules/podman
          ./modules/mover
          ./modules/appdata-backup

          # Import the machine config + secrets
          ./machines
          ./machines/emily
          ./secrets
          agenix.nixosModules.default

          # Services and applications
          ./services/dashy
          ./services/invoiceninja
          ./services/paperless-ngx
          ./services/traefik
          ./services/deluge
          ./services/arr
          ./services/jellyfin
          ./services/vaultwarden

          # User-specific configurations
          ./users/notthebee
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = false; # makes hm use nixos's pkgs value
            home-manager.extraSpecialArgs = { inherit inputs; }; # allows access to flake inputs in hm modules
            home-manager.users.notthebee.imports = [ 
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
