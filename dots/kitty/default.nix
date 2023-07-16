{
  programs.kitty = {
    enable = true;
    theme = "Nord";
    keybindings = {
      "cmd+w" = "no_op";
      "cmd+t" = "no_op";
    };
    shellIntegration = {
      enableFishIntegration = true;
    };
    extraConfig = ''
      macos_titlebar_color #2E3440
      window_padding_width 0
      window_margin_width 0
      adjust_line_height 105%
      font_family      ComicCodeLigatures Nerd Font
      font_size 15.0
      modify_font cell_width 95%
      shell /run/current-system/sw/bin/tmux
    '';

  };
}
