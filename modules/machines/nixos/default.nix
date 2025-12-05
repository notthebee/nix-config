{
  lib,
  self,
  ...
}:
let
  entries = builtins.attrNames (builtins.readDir ./.);
  configs = builtins.filter (dir: builtins.pathExists (./. + "/${dir}/configuration.nix")) entries;
  homeManagerCfg = userPackages: extraImports: {
    home-manager.useGlobalPkgs = false;
    home-manager.extraSpecialArgs = {
      inherit (self) inputs;
    };
    home-manager.users.notthebee.imports = [
      self.inputs.agenix.homeManagerModules.default
      self.inputs.nix-index-database.homeModules.nix-index
      self.inputs.nixvim.homeModules.nixvim
      ../../users/notthebee/dots.nix
      ../../users/notthebee/age.nix
    ]
    ++ extraImports;
    home-manager.backupFileExtension = "bak";
    home-manager.useUserPackages = userPackages;
  };
in
{

  flake.nixosConfigurations =
    let
      nixpkgsMap = {
        maya = "-unstable";
      };
      myNixosSystem =
        name: self.inputs."nixpkgs${lib.attrsets.attrByPath [ name ] "" nixpkgsMap}".lib.nixosSystem;
    in
    lib.listToAttrs (
      builtins.map (
        name:
        lib.nameValuePair name (
          (myNixosSystem name) {
            system = "x86_64-linux";
            specialArgs = {
              inherit (self) inputs;
              self = {
                nixosModules = self.nixosModules;
              };
            };

            modules = [
              ../../homelab
              ../../misc/email
              ../../misc/tg-notify
              ../../misc/mover
              ../../misc/withings2intervals
              self.inputs.agenix.nixosModules.default
              self.inputs.adios-bot.nixosModules.default
              self.inputs.autoaspm.nixosModules.default
              self.inputs.invoiceplane.nixosModules.default
              self.inputs."home-manager${
                lib.attrsets.attrByPath [ name ] "" nixpkgsMap
              }".nixosModules.home-manager
              (./. + "/_common/default.nix")
              (./. + "/${name}/configuration.nix")
              ../../users/notthebee
              (homeManagerCfg false [ ])
            ];
          }
        )
      ) configs
    );
}
