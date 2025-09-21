{
  lib,
  self,
  ...
}:
let
  entries = builtins.attrNames (builtins.readDir ./.);
  configs = builtins.filter (dir: builtins.pathExists (./. + "/${dir}/configuration.nix")) entries;
  homeManagerCfg = userPackages: {
    home-manager.useGlobalPkgs = false;
    home-manager.extraSpecialArgs = {
      inherit (self) inputs;
    };
    home-manager.users.notthebee.imports = [
      self.inputs.agenix.homeManagerModules.default
      self.inputs.nix-index-database.homeModules.nix-index
      ../../users/notthebee/dots.nix
      ../../users/notthebee/age.nix
      ../../dots/tmux
      ../../dots/kitty
    ];
    home-manager.backupFileExtension = "bak";
    home-manager.useUserPackages = userPackages;
  };
in
{
  flake.darwinConfigurations = lib.listToAttrs (
    builtins.map (
      name:
      lib.nameValuePair name (
        self.inputs.nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = {
            inherit (self) inputs;
            self = {
              darwinModules = self.darwinModules;
            };
          };

          modules = [
            self.inputs.agenix.darwinModules.default
            self.inputs.home-manager-unstable.darwinModules.home-manager
            (./. + "/_common/default.nix")
            (./. + "/${name}/configuration.nix")
            (self.inputs.nixpkgs-unstable.lib.attrsets.recursiveUpdate (homeManagerCfg true) {
              home-manager.users.notthebee.home.homeDirectory =
                self.inputs.nixpkgs-unstable.lib.mkForce "/Users/notthebee";
            })
          ];
        }
      )
    ) configs
  );
}
