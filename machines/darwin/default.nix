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
      users.beethenot = {
        nixpkgs.overlays = [ 
        inputs.nixpkgs-firefox-darwin.overlay 
        inputs.nur.overlay
        ];
        home.homeDirectory = lib.mkForce "/Users/beethenot";
        imports = [
          inputs.nix-index-database.hmModules.nix-index
          ../../users/beethenot/dots.nix
          ../../dots/tmux
          ../../dots/firefox
          ../../dots/kitty
        ];
      };

    backupFileExtension = "bak";
    useUserPackages = true;
  };

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };
    brewPrefix = "/opt/homebrew/bin";
    caskArgs = {
      no_quarantine = true;
    };

    masApps = {
      "hidden-bar" = 1452453066;
      "bitwarden" = 1352778147;
      "amorphousdiskmark" = 1168254295;
      "wireguard" = 1451685025;
      "parcel" = 639968404;
    };


    casks = [
      "discord"
      "homebrew/cask/docker"
      "notion"
      "telegram"
      "spotify"
      "signal"
      "karabiner-elements"
      "grid"
      "scroll-reverser"
      "utm"
      "topnotch"
      "bambu-studio"
      "monitorcontrol"
    ];
  };



  services.nix-daemon.enable = lib.mkForce true;

  programs.fish.enable = true;

  system.stateVersion = 4;

  environment.systemPath = [
   /run/current-system/sw/bin
  ];

  environment.systemPackages = with pkgs; [
    wget
    git-crypt
      iperf3
      deploy-rs
      exa
      neofetch
      tmux
      rsync
      ncdu
      nmap
      jq
      bitwarden-cli
      ripgrep
      sqlite
      inputs.agenix.packages."${system}".default 
  ];

}
