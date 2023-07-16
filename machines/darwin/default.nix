{ inputs, pkgs, lib, ... }:
{
  imports = [ <home-manager/nix-darwin> ];
  home-manager = {
    useGlobalPkgs = false; # makes hm use nixos's pkgs value
      extraSpecialArgs = { inherit inputs; }; # allows access to flake inputs in hm modules
      users.notthebee = {
        nixpkgs.overlays = [ 
        inputs.nixpkgs-firefox-darwin.overlay 
        inputs.nur.overlay
        ];
        home.homeDirectory = lib.mkForce "/Users/notthebee";
        imports = [
          inputs.nix-index-database.hmModules.nix-index
          ../../users/notthebee/dots.nix
          ../../dots/tmux
          ../../dots/firefox
          ../../dots/kitty
        ];
      };
    backupFileExtension = "bak";
    useUserPackages = true;
  };

  services.nix-daemon.enable = lib.mkForce true;

  programs.fish.enable = true;

  system.stateVersion = 4;

  environment.systemPackages = with pkgs; [
    wget
    iperf3
    exa
    neofetch
    tmux
    rsync
    ncdu
    nmap
    jq
    ripgrep
    sqlite
    inputs.agenix.packages."${system}".default 
  ];

}
