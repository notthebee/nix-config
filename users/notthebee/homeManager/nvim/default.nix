{ inputs, lib, config, pkgs, ... }: {
  imports = [ inputs.nixvim.homeManagerModules.nixvim
  ];


  home.packages = with pkgs; [
    figlet
  ];
  programs.neovim = {
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
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
      neo-tree = {
        enable = true;
        closeIfLastWindow = true;
        window.mappings = {
         h = "close_node";
         l = "open";
         sf = "close_window";
        };
      };
      fugitive = {
        enable = true;
      };
      lualine = {
        enable = true;
      };
      startify = {
        enable = true;
        customHeader = "startify#pad(split(system('figlet -f larry3d neovim'), '\n'))";
      };
      indent-blankline = {
        enable = true;
        filetypeExclude = [
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
      lsp = {
        enable = true;
        servers.bashls.enable = true;
      };
    };
    extraPlugins = with pkgs.vimPlugins; [
      ansible-vim
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
      event = [ "InsertLeave" ];
      pattern = [ "*" ];
      command = "set nopaste";
    }
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
    extraConfigLua = ''
      vim.api.nvim_set_hl(0, "MatchParen", { bg="#4c566a", fg="#88c0d0" })
      '';
    extraConfigVim = ''
      filetype plugin indent on
      set termguicolors
      '';
    maps = {
      normal."sf" = {
        silent = true;
        action = "<cmd>NeoTreeRevealToggle<CR>";
      };
    };
  };
                                    }
