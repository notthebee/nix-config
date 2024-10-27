{
  inputs,
  pkgs,
  lib,
  ...
}:
{
  environment.shellInit = ''
    ulimit -n 2048
  '';

  imports = [ ./work.nix ];

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
      "libreoffice"
      "signal"
      "grid"
      "google-chrome"
      "handbrake"
      "tailscale"
      "bambu-studio"
      "element"
      "microsoft-outlook"
      "monitorcontrol"
      "zen-browser"
    ];
  };
  environment.systemPackages = with pkgs; [
    (python311Full.withPackages (
      ps: with ps; [
        pip
        jmespath
        requests
        setuptools
        pyyaml
        pyopenssl
      ]
    ))
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
    nss
    nss.tools
    mkcert
    karabiner-elements
    vscode
    pulumi-bin
    pfetch
    devenv
    nixfmt-rfc-style
  ];

  services.nix-daemon.enable = lib.mkForce true;

  system.stateVersion = 4;
}
