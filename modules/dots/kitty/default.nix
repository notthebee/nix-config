{
  programs.kitty = {
    enable = true;
    themeFile = "Nord";
    keybindings = {
      "cmd+w" = "no_op";
      "cmd+t" = "no_op";
    };
    shellIntegration = {
      enableZshIntegration = true;
    };
    settings = {
      macos_titlebar_color = "#2E3440";
      window_padding_width = 0;
      window_margin_width = 0;
      adjust_line_height = "120%";
      font_family = "Comic Code Ligatures";
      font_size = "16.0";
      shell = "/run/current-system/sw/bin/tmux";
    };
    extraConfig = ''
      # "Nerd Fonts - Pomicons"
      symbol_map  U+E000-U+E00D Symbols Nerd Font

      # "Nerd Fonts - Powerline"
      symbol_map U+e0a0-U+e0a2,U+e0b0-U+e0b3 Symbols Nerd Font

      # "Nerd Fonts - Powerline Extra"
      symbol_map U+e0a3-U+e0a3,U+e0b4-U+e0c8,U+e0cc-U+e0d2,U+e0d4-U+e0d4 Symbols Nerd Font

      # "Nerd Fonts - Symbols original"
      symbol_map U+e5fa-U+e62b Symbols Nerd Font

      # "Nerd Fonts - Devicons"
      symbol_map U+e700-U+e7c5 Symbols Nerd Font

      # "Nerd Fonts - Font awesome"
      symbol_map U+f000-U+f2e0 Symbols Nerd Font

      # "Nerd Fonts - Font awesome extension"
      symbol_map U+e200-U+e2a9 Symbols Nerd Font

      # "Nerd Fonts - Octicons"
      symbol_map U+f400-U+f4a8,U+2665-U+2665,U+26A1-U+26A1,U+f27c-U+f27c Symbols Nerd Font

      # "Nerd Fonts - Font Linux"
      symbol_map U+F300-U+F313 Symbols Nerd Font

      #  Nerd Fonts - Font Power Symbols"
      symbol_map U+23fb-U+23fe,U+2b58-U+2b58 Symbols Nerd Font

      #  "Nerd Fonts - Material Design Icons"
      symbol_map U+f500-U+fd46 Symbols Nerd Font

      # "Nerd Fonts - Weather Icons"
      symbol_map U+e300-U+e3eb Symbols Nerd Font

      # Misc Code Point Fixes
      symbol_map U+21B5,U+25B8,U+2605,U+2630,U+2632,U+2714,U+E0A3,U+E615,U+E62B Symbols Nerd Font
    '';

  };
}
