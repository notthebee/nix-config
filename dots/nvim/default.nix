{ inputs, lib, config, pkgs, ... }:
let
coc = import ./coc.nix;
in
{
  imports = [ inputs.nixvim.homeManagerModules.nixvim
  ];


  home.packages = with pkgs; [
    figlet
    nodejs
    ripgrep
    rnix-lsp
  ];

  programs.neovim = {
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
  };

  xdg.configFile = {
    "nvim/coc-settings.json" = {
      source = builtins.toFile "coc-settings.json" (builtins.toJSON (coc { homeDir = config.xdg.configHome; }));
    };
  };

  programs.nixvim = {
    enable = true;
    colorschemes.nord.enable = true;
    plugins = {
      project-nvim = {
        enable = true;
      };
      telescope = {
        enable = true;
      };
      fugitive = {
        enable = true;
      };
      lualine = {
        enable = true;
        sections = {
          lualine_x = [
            "diagnostics"
            "encoding"
            "filetype"
          ];
        };
      };
      startify = {
        enable = true;
        customHeader = "startify#pad(split(system('figlet -f larry3d neovim'), '\n'))";
      };
      indent-blankline = {
        enable = true;
        exclude.filetypes = [
          "startify"
        ];
      };
      barbar = {
        enable = true;
      };
      gitgutter = {
        enable = true;
      };
      surround = {
        enable = true;
      };
      nvim-colorizer = {
        enable = true;
      };
    };
    extraPlugins = with pkgs.vimPlugins; [
      ansible-vim
      coc-nvim
      suda-vim
    ];
    options = {
      number = true;
      syntax = "enable";
      fileencodings = "utf-8,sjis,euc-jp,latin";
      encoding = "utf-8";
      title = true;
      autoindent = true;
      background = "dark";
      backup  = false;
      hlsearch = true;
      showcmd = true;
      cmdheight = 1;
      laststatus = 2;
      scrolloff = 10;
      expandtab = true;
      shell = "fish";
      backupskip = "/tmp/*,/private/tmp/*";
      inccommand = "split";
      ruler = false;
      showmatch = false;
      lazyredraw = true;
      ignorecase = true;
      smarttab = true;
      shiftwidth = 2;
      tabstop = 2;
      ai = true;
      ci = true;
      wrap = true;
      backspace = "start,eol,indent";
      path = "vim.opts.path \+ **";
      wildignore = "vim.opts.wildignore \+ */node_modules/*";
      cursorline = true;
      exrc = true;
      mouse = "a";
      suffixesadd = ".js,.es,.jsx,.json,.css,.less,.sass,.styl,.php,.py,.md";
    };

    autoCmd = [
    {
      event = [ "WinEnter" ];
      pattern = [ "*" ];
      command = "set cul";
    }
    {
      event = [ "WinLeave" ];
      pattern = [ "*" ];
      command = "set nocul";
    }
    ];
    highlight = {
      BufferCurrent = {
        fg = "#eceff4";
        bg = "#434c5e";
        bold = true;
      };
      BufferCurrentMod = {
        fg = "#ebcb8b";
        bg = "#434c5e";
        bold = true;
      };
      BufferCurrentSign = {
        fg = "#4c566a";
        bg = "#4c566a";
      };
      BufferCurrentTarget = {
        bg = "#434c5e";
      };
      BufferInactive = {
        fg = "#4c566a";
        bg = "none";
      };
      BufferInactiveSign = {
        fg = "#4c566a";
        bg = "none";
      };
      BufferInactiveMod = {
        fg = "#ebcb8b";
        bg = "none";
      };
      BufferTabpageFill = {
        fg = "#4c566a";
        bg = "none";
      };
    };
    globals = {
      coc_filetype_map = {
        "yaml.ansible" = "ansible";
      };
      coc_global_extensions = [
        "coc-explorer"
        "@yaegassy/coc-ansible"
      ];
      suda_smart_edit = 1;
      "suda#nopass" = 1;
    };
    extraConfigLua = ''
      vim.api.nvim_set_hl(0, "MatchParen", { bg="#4c566a", fg="#88c0d0" })
      '';
    extraConfigVim = ''
      inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<CR>"
      set undofile
      set clipboard+=unnamedplus
      function CheckForExplorer()
      if CocAction('runCommand', 'explorer.getNodeInfo', 'closest') isnot# v:null
        CocCommand explorer --toggle
          endif
          endfunction
          '';
    keymaps = [
      {
        mode = "n";
        key = "sf";
        action = "<cmd>CocCommand explorer<cr>";
        options = {
          silent = true;
        };
      }
      {
        mode = "n";
        key = "p";
        action = "p`]<Esc>";
        options = {
          silent = true;
        };
      }
      {
        mode = "n";
        key = "<A-CR>";
        action = "O<Esc>";
        options = {
          silent = true;
          remap = true;
        };
      }
      {
        mode = "n";
        key = "<CR>";
        action = "o<Esc>";
        options = {
          silent = true;
          remap = true;
        };
      }
      {
        mode = "n";
        key = ";r";
        action = ":call CheckForExplorer()<CR> <cmd>lua require('telescope.builtin').live_grep()<cr>";
        options = {
          silent = true;
        };
      }
      {
        mode = "n";
        key = ";f";
        action = ":call CheckForExplorer()<CR> <cmd>lua require('telescope.builtin').find_files()<cr>";
        options = {
          silent = true;
        };
      }
      {
        mode = "n";
        key = ";b";
        action = ":call CheckForExplorer()<CR> <cmd>lua require('telescope.builtin').file_browser()<cr>";
        options = {
          silent = true;
        };
      }
      {
        mode = "n";
        key = "\\";
        action = ":call CheckForExplorer()<CR> <cmd>Telescope buffers<cr>";
        options = {
          silent = true;
        };
      }
      {
        mode = "n";
        key = ";;";
        action = ":call CheckForExplorer()<CR> <cmd>Telescope help_tags<cr>";
        options = {
          silent = true;
        };
      }
    ];
  };
}
