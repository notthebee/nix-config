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
      "warp"
      "telegram"
      "libreoffice"
      "signal"
      "karabiner-elements"
      "grid"
      "monitorcontrol"
      "google-chrome"
      "schildichat"
      "monitorcontrol"
      "handbrake"
      "tailscale"
      "bambu-studio"
      "thunderbird"
    ];
  };
  environment.systemPackages = with pkgs; [
      (python311.withPackages(ps: with ps; [ 
      pip 
      jmespath
      requests
      setuptools
      pyyaml
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
      gocode
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
      deploy-rs
      eza
      neofetch
      tmux
      rsync
      ncdu
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
      coconutbattery
  ];

  services.nix-daemon.enable = lib.mkForce true;

  system.stateVersion = 4;
  }
