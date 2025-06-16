{
  pkgs,
  config,
  inputs,
  lib,
  ...
}:
{
  home.packages = with pkgs; [ grc ];
  age.secrets = lib.mkIf (pkgs.system == "aarch64-darwin") {
    bwSession.file = "${inputs.secrets}/bwSession.age";
  };

  programs = {
    fzf = {
      enable = true;
      enableZshIntegration = true;
      colors = {
        fg = "#D8DEE9";
        bg = "#2E3440";
        hl = "#A3BE8C";
        "fg+" = "#D8DEE9";
        "bg+" = "#434C5E";
        "hl+" = "#A3BE8C";
        pointer = "#BF616A";
        info = "#4C566A";
        spinner = "#4C566A";
        header = "#4C566A";
        prompt = "#81A1C1";
        marker = "#EBCB8B";
      };
    };
    starship = {
      enable = true;
      settings = {
        add_newline = false;
        gcloud = {
          detect_env_vars = [ "GOOGLE_CLOUD" ];
        };
        aws = {
          disabled = true;
        };
      };
    };
    zoxide = {
      enable = true;
      enableZshIntegration = true;
      options = [ "--cmd cd" ];
    };

    direnv = {
      enable = true;
      enableZshIntegration = true;
    };

    zsh = {
      enable = true;
      enableCompletion = false;
      zplug = {
        enable = true;
        plugins = [
          { name = "zsh-users/zsh-autosuggestions"; }
          { name = "zsh-users/zsh-syntax-highlighting"; }
          { name = "zsh-users/zsh-completions"; }
          { name = "zsh-users/zsh-history-substring-search"; }
          { name = "unixorn/warhol.plugin.zsh"; }
        ];
      };
      shellAliases = {
        la = "ls --color -lha";
        df = "df -h";
        du = "du -ch";
        ipp = "curl ipinfo.io/ip";
        yh = "yt-dlp --continue --no-check-certificate --format=bestvideo+bestaudio --exec='ffmpeg -i {} -c:a copy -c:v copy {}.mkv && rm {}'";
        yd = "yt-dlp --continue --no-check-certificate --format=bestvideo+bestaudio --exec='ffmpeg -i {} -c:v prores_ks -profile:v 1 -vf fps=25/1 -pix_fmt yuv422p -c:a pcm_s16le {}.mov && rm {}'";
        ya = "yt-dlp --continue --no-check-certificate --format=bestaudio -x --audio-format wav";
        aspm = "sudo lspci -vv | awk '/ASPM/{print $0}' RS= | grep --color -P '(^[a-z0-9:.]+|ASPM )'";
        mkdir = "mkdir -p";
        # Only do `nix flake update` if flake.lock hasn't been updated within an hour
        deploy-nix = "f() { if [[ $(find . -mmin -60 -type f -name flake.lock | wc -c) -eq 0 ]]; then nix flake update; fi && deploy .#$1 --remote-build -s --auto-rollback false && rsync -ax --delete ./ $1:/etc/nixos/ };f";
      };

      initContent = ''
        # Cycle back in the suggestions menu using Shift+Tab
        bindkey '^[[Z' reverse-menu-complete

        bindkey '^B' autosuggest-toggle
        # Make Ctrl+W remove one path segment instead of the whole path
        WORDCHARS=''${WORDCHARS/\/}

        # Highlight the selected suggestion
        zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}
        zstyle ':completion:*' menu yes=long select

        ${
          if (pkgs.system == "aarch64-darwin") then
            ''
              path=("$HOME/.nix-profile/bin" "/run/wrappers/bin" "/etc/profiles/per-user/$USER/bin" "/nix/var/nix/profiles/default/bin" "/run/current-system/sw/bin" "/opt/homebrew/bin" $path)
              export BW_SESSION=$(${pkgs.coreutils}/bin/cat ${config.age.secrets.bwSession.path})
              export DOCKER_HOST="unix://$HOME/.colima/default/docker.sock"
              alias lsblk="diskutil list"
              ulimit -n 2048
            ''
          else
            ""
        }

          export EDITOR=nvim || export EDITOR=vim
          export LANG=en_US.UTF-8
          export LC_CTYPE=en_US.UTF-8
          export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

          source $ZPLUG_HOME/repos/unixorn/warhol.plugin.zsh/warhol.plugin.zsh
          bindkey '^[[A' history-substring-search-up
          bindkey '^[[B' history-substring-search-down

          if command -v motd &> /dev/null
          then
            motd
          fi
          bindkey -e
      '';
    };
  };
}
