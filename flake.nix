{
  inputs = {
  nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
  nixvim.url = "github:pta2002/nixvim/nixos-23.05";
  home-manager.url = "github:nix-community/home-manager/release-23.05";
  home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, nixvim, ... }@inputs: {

    nixosConfigurations = {
    emily = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ 
      ./machines
      ./modules/zfs-root
      ./modules/docker
      ./machines/emily
      
      # User-specific configurations
      ./users/notthebee
      home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = false; # makes hm use nixos's pkgs value
          home-manager.extraSpecialArgs = { inherit inputs; }; # allows access to flake inputs in hm modules
          home-manager.users.notthebee.imports = [ ./users/notthebee/home ];
      }
      ];
    };
  };
};
}
