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

    casks = [
      "notion"
      "telegram"
      "signal"
      "karabiner-elements"
      "grid"
      "bambu-studio"
      "monitorcontrol"
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
      ansible
      ansible-lint
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
      spotify
      httpie
      slack
      mattermost
  ];

  services.nix-daemon.enable = lib.mkForce true;

  system.stateVersion = 4;
  }
