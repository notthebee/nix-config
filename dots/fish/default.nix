{ inputs, pkgs, lib, config, ... }: {
  home.packages = with pkgs; [
    grc
    fishPlugins.grc
  ];


  age.secrets.bwSessionFish = {
    file = ../../secrets/bwSessionFish.age;
  };

  programs.fish = {
    enable = true;
    loginShellInit = ''
      if test (uname) = Darwin
        fish_add_path -m "/run/current-system/sw/bin"
        fish_add_path --move --path $HOME/.nix-profile/bin /run/wrappers/bin /etc/profiles/per-user/$USER/bin /nix/var/nix/profiles/default/bin /run/current-system/sw/bin /opt/homebrew/bin
      end
      switch (whoami)
        case "beethenot"
          export BW_SESSION=(${pkgs.coreutils}/bin/cat ${config.age.secrets.bwSessionFish.path})
        case "notthebee"
        :
      end
    '';
    interactiveShellInit = ''
      set fish_color_autosuggestion brblack
      set fish_color_command blue
      set fish_color_comment black
      set fish_color_comment bryellow
      set fish_color_comment brgreen
      set fish_color_end brgreen
      set fish_color_error red
      set fish_color_escape bryellow
      set fish_color_operator green
      set fish_color_operator brgreen
      set fish_color_operator -o brgreen
      set fish_color_param green
      set fish_color_param normal
      set fish_color_quote magenta
      set fish_color_redirection green
      set fish_pager_color_completion brgreen
      set fish_pager_color_description green
      set fish_pager_color_prefix blue
      set fish_pager_color_prefix blue --underline
      set fish_pager_color_progress 'brwhite' '--background=blue'

      export EDITOR=nvim || export EDITOR=vim
      export LANG=en_US.UTF-8
      export LC_CTYPE=en_US.UTF-8
      export DOCKER_HOST="unix://$HOME/.colima/default/docker.sock"

      switch (uname)
    case "*Darwin"
        alias lsblk="diskutil list"
        ulimit -n 2048
          switch (whoami)
    case "notthebee"
            :
    case "*"
              alias brew="multi_user_brew"
                end


    case "*Linux"
                :
                  end

                  set -l exa_available (which exa)
                  if test -n "$exa_unavailable"
                    set -l exa_git_unavailable (exa --version | grep "\-git")
                      if test -n "$exa_git_unavailable"
                        alias ls="exa --icons"
                      else
                        alias ls="exa --icons --git"
                          end
                          end
                          '';
                shellAliases = {
                  la = "ls -lha";
                  df = "df -h";
                  du = "du -ch";
                  ipp = "curl ipinfo.io/ip";
                  yh = "yt-dlp --continue --no-check-certificate --format=bestvideo+bestaudio --exec='ffmpeg -i {} -c:a copy -c:v copy {}.mkv && rm {}'";
                  yd = "yt-dlp --continue --no-check-certificate --format=bestvideo+bestaudio --exec='ffmpeg -i {} -c:v prores_ks -profile:v 1 -vf fps=25/1 -pix_fmt yuv422p -c:a pcm_s16le {}.mov && rm {}'";
                  ya = "yt-dlp --continue --no-check-certificate --format=bestaudio -x --audio-format wav";
                  pip_upgrade_all = "pip3 list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1 | xargs -n1 pip3 install -U";
                };
                shellAbbrs = {
                  aspm = "sudo lspci -vv | awk '/ASPM/{print $0}' RS= | grep --color -P '(^[a-z0-9:.]+|ASPM )'";
                  mkdir = "mkdir -p";
                };

                plugins = [
                # Enable a plugin (here grc for colorized command output) from nixpkgs
                { name = "grc"; src = pkgs.fishPlugins.grc.src; }
                ];
  };
  xdg.configFile = {
    "fish/functions" = {
      source = ./functions;
      recursive = true;
    };
  };
  }
