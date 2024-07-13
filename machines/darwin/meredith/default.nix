{ inputs, pkgs, lib, ... }:
{
  environment.shellInit = ''
    ulimit -n 2048
    '';

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
    brews = [
      "ansible"
      "ansible-lint"
      "pulumi"
    ];
    casks = [
      "notion"
      "telegram"
      "libreoffice"
      "signal"
      "karabiner-elements"
      "grid"
      "monitorcontrol"
      "google-chrome"
      "handbrake"
      "tailscale"
      "bambu-studio"
      "element"
    ];
  };
  environment.systemPackages = with pkgs; [
      (python311Full.withPackages(ps: with ps; [ 
      pip 
      jmespath
      requests
      setuptools
      pyyaml
      pyopenssl
      ]))
      ansible-language-server
      vault
      yq
      git-lfs
      pre-commit
      bfg-repo-cleaner
      go
      gotools
      gopls
      go-outline
      gopls
      gopkgs
      gocode-gomod
      godef
      golint
      colima
      docker
      docker-compose
      utm
      wget
      git-crypt
      iperf3
      eza
      neofetch
      tmux
      rsync
      nmap
      jq
      yq
      ripgrep
      sqlite
      pwgen
      gnupg
      inputs.agenix.packages."${system}".default 
      bitwarden-cli
      yt-dlp
      ffmpeg
      chromedriver
      mosh
      discord
      git-filter-repo
      spotify
      httpie
      slack
      mattermost
      sentry-cli
      vscode
      google-cloud-sdk
      pinentry.curses
      nixos-rebuild
      deploy-rs
      nixpkgs-fmt
      nil
  ];

  services.nix-daemon.enable = lib.mkForce true;

  system.stateVersion = 4;
  }
