inputs:
let
  homeManagerCfg = userPackages: extraImports: {
    home-manager.useGlobalPkgs = false;
    home-manager.extraSpecialArgs = {
      inherit inputs;
    };
    home-manager.users.notthebee.imports = [
      inputs.agenix.homeManagerModules.default
      inputs.nix-index-database.hmModules.nix-index
      ./users/notthebee/dots.nix
    ];
    home-manager.backupFileExtension = "bak";
    home-manager.useUserPackages = userPackages;
  };
in
{

  mkDarwin = machineHostname: extraHmModules: extraModules: {
    darwinConfigurations.${machineHostname} = inputs.nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      specialArgs = {
        inherit inputs;
      };
      modules = [
        "${inputs.secrets}/default.nix"
        inputs.agenix.darwinModules.default
        ./machines/darwin
        ./machines/darwin/${machineHostname}
        inputs.home-manager.darwinModules.home-manager
        (inputs.nixpkgs.lib.attrsets.recursiveUpdate (homeManagerCfg true extraHmModules) {
          home-manager.users.notthebee.home.homeDirectory = inputs.nixpkgs.lib.mkForce "/Users/notthebee";
        })
      ];
    };
  };
  mkNixos = machineHostname: nixpkgsVersion: extraModules: {
    deploy.nodes.${machineHostname} = {
      hostname = machineHostname;
      profiles.system = {
        user = "root";
        sshUser = "notthebee";
        path =
          inputs.deploy-rs.lib.x86_64-linux.activate.nixos
            inputs.self.nixosConfigurations.${machineHostname};
      };
    };
    nixosConfigurations.${machineHostname} = nixpkgsVersion.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        inherit inputs;
        vars = import ./machines/nixos/vars.nix;
      };
      modules = [
        ./homelab
        ./machines/nixos
        ./machines/nixos/${machineHostname}
        ./modules/email
        "${inputs.secrets}/default.nix"
        inputs.agenix.nixosModules.default
        ./users/notthebee
        (homeManagerCfg false)
        inputs.home-manager.darwinModules.home-manager
      ] ++ extraModules;
    };
  };
  mkMerge = inputs.nixpkgs.lib.lists.foldl' (
    a: b: inputs.nixpkgs.lib.attrsets.recursiveUpdate a b
  ) { };
}
