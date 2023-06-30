{
  inputs = {
  nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
  };

  outputs = { self, nixpkgs }: {
    nixosConfigurations.emily = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ 
      ./machines
      ./modules/zfs-root
      ./modules/docker
      ./modules/home-manager
      ./machines/emily
      ];
    };
  };
}
