{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
  };

  outputs = { self, nixpkgs }@inputs:
    let
      local-overlays = import ./overlays;
      overlays = with inputs;
        [
          local-overlays
        ];
      lib = nixpkgs.lib;
      mkHost = { zfs-root, my-config, pkgs, system, ... }:
        lib.nixosSystem {
          inherit system;
          modules = [
            ./modules
            (import ./configuration.nix {
              inherit zfs-root my-config inputs pkgs lib;
            })
          ];
        };
    in {
    nixosConfigurations = {
        emily = let
          system = "x86_64-linux";
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
        in mkHost (import ./machines/emily { inherit system pkgs; });
      };
    };
}
