{
  inputs = {
  nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
  nixvim.url = "github:pta2002/nixvim/nixos-23.05";
  home-manager.url = "github:nix-community/home-manager/release-23.05";
  home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, nixvim, ... }@inputs: {

    homeConfigurations = {
    notthebee = home-manager.lib.homeManagerConfiguration {
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
    extraSpecialArgs = { inherit inputs; };
    modules = [ ./users/notthebee/homeManager ];
    };
    };

    nixosConfigurations = {
    emily = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ 
      ./machines
      ./modules/zfs-root
      ./modules/docker
      ./machines/emily
      
      # User-specific configurations
      ./users/notthebee/system.nix
      ];
    };
    };
  };
}
