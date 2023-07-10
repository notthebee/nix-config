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
  };

  outputs = { self, nixpkgs, home-manager, recyclarr-configs, nixvim, agenix, ... }@inputs: {

    nixosConfigurations = {
      emily = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { 
        inherit inputs; 
        vars = import ./machines/emily/vars.nix;
        };
        modules = [ 
          # Base configuration and modules
          ./modules/zfs-root
          ./modules/email
          ./modules/tg-notify
          ./modules/podman
          ./modules/tailscale

          # Import the machine config + secrets
          ./machines
          ./machines/emily
          ./secrets
          agenix.nixosModules.default

          # Services and applications
          ./services/homepage
          ./services/invoiceninja
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
              ./users/notthebee/dots.nix 
            ];
            home-manager.backupFileExtension = "bak";
          }
        ];
      };
    };
  };
}
