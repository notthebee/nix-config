{ inputs, pkgs, lib, ... }:
{
  imports = [ <home-manager/nix-darwin> ];
  home-manager = {
    useGlobalPkgs = false; # makes hm use nixos's pkgs value
      extraSpecialArgs = { inherit inputs; }; # allows access to flake inputs in hm modules
      users.notthebee = { config, pkgs, ... }: {
        nixpkgs.overlays = [ 
        inputs.nixpkgs-firefox-darwin.overlay 
        inputs.nur.overlay
        ];
        home.homeDirectory = lib.mkForce "/Users/notthebee";
        
        imports = [
          inputs.nix-index-database.hmModules.nix-index
          inputs.agenix.homeManagerModules.default
          ../../users/notthebee/dots.nix
          ../../dots/tmux
          ../../dots/firefox
          ../../dots/kitty
        ];
      };
      users.beethenot = { config, pkgs, ... }: {
        nixpkgs.overlays = [ 
        inputs.nixpkgs-firefox-darwin.overlay 
        inputs.nur.overlay
        ];
        home.homeDirectory = lib.mkForce "/Users/beethenot";
        imports = [
          inputs.nix-index-database.hmModules.nix-index
          inputs.agenix.homeManagerModules.default
          ../../users/beethenot/default.nix
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
      "notion"
      "telegram"
      "spotify"
      "signal"
      "karabiner-elements"
      "grid"
      "scroll-reverser"
      "topnotch"
      "bambu-studio"
      "monitorcontrol"
    ];
  };



  services.nix-daemon.enable = lib.mkForce true;

  programs.fish.enable = true;

  system.stateVersion = 4;

  environment.systemPackages = with pkgs; [
    wget
    git-crypt
    iperf3
    deploy-rs
    eza
    neofetch
    tmux
    rsync
    ncdu
    nmap
    jq
    yq
    bitwarden-cli
    ripgrep
    sqlite
    pwgen
    gnupg
    inputs.agenix.packages."${system}".default 
    direnv
    yt-dlp
    ffmpeg
    php
    chromedriver
  ];

}
