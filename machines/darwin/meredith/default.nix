{
  inputs,
  pkgs,
  ...
}:
{
  system.primaryUser = "notthebee";
  environment.shellInit = ''
    ulimit -n 2048
  '';

  imports = [
    "${inputs.secrets}/work.nix"
    ./secrets.nix
  ];

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "uninstall";
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
      "raycast"
      "mattermost"
      "jitsi-meet"
    ];
    brews = [
      "pulumi"
    ];
  };
  environment.systemPackages = with pkgs; [
    (python312Full.withPackages (
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
    just
    ripgrep
    sqlite
    pwgen
    gnupg
    inputs.agenix.packages."${system}".default
    yt-dlp
    ffmpeg
    discord
    git-filter-repo
    spotify
    slack
    google-cloud-sdk
    pinentry.curses
    deploy-rs
    nixpkgs-fmt
    nil
    nss
    nss.tools
    mkcert
    karabiner-elements
    devenv
    nixfmt-rfc-style
    opentofu
    talosctl
  ];

  system.stateVersion = 4;
}
