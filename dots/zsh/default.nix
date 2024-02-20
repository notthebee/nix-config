{ inputs, pkgs, lib, config, ... }: {
  home.packages = with pkgs; [
    grc
  ];

  age.secrets.bwSessionFish = {
    file = ../../secrets/bwSessionFish.age;
  };

  programs.zsh = {
    enable = true;
    zplug = {
      enable = true;
      plugins = [
      { name = "zsh-users/zsh-autosuggestions"; }
      { name = "zsh-users/zsh-syntax-highlighting"; }
      { name = "zsh-users/zsh-completions"; }
      { name = "zsh-users/zsh-history-substring-search"; }
      { name = "unixorn/warhol.plugin.zsh"; }
      { name = "notthebee/prompt"; tags = [ as:theme ]; }
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
      };

    initExtra = ''
    # Cycle back in the suggestions menu using Shift+Tab
    bindkey '^[[Z' reverse-menu-complete

    # Make Ctrl+W remove one path segment instead of the whole path
    WORDCHARS=''${WORDCHARS/\/}

    # Highlight the selected suggestion
    zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}
    zstyle ':completion:*' menu yes=long select

      if [ $(uname) = "Darwin" ]; then 
        path=("$HOME/.nix-profile/bin" "/run/wrappers/bin" "/etc/profiles/per-user/$USER/bin" "/nix/var/nix/profiles/default/bin" "/run/current-system/sw/bin" "/opt/homebrew/bin" $path)
      fi
      
      if [ $(whoami) = "beethenot" ]; then
        export BW_SESSION=$(${pkgs.coreutils}/bin/cat ${config.age.secrets.bwSessionFish.path})
      fi
      export EDITOR=nvim || export EDITOR=vim
      export LANG=en_US.UTF-8
      export LC_CTYPE=en_US.UTF-8
      export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES


      if [ $(uname) = "Darwin" ]; then 
        alias lsblk="diskutil list"
        ulimit -n 2048
      fi 

      if [ $(whoami) = "beethenot" ]; then
        alias brew="pushd / && sudo -Hu notthebee brew $argv & popd"
      fi
      source $ZPLUG_HOME/repos/unixorn/warhol.plugin.zsh/warhol.plugin.zsh
      bindkey '^[[A' history-substring-search-up
      bindkey '^[[B' history-substring-search-down
      '';
  };
  }
