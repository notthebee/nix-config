{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    figlet
    nodejs
    ripgrep
    terraform-ls
  ];

  programs.neovim = {
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
  };

  programs.nixvim = {
    enable = true;
    colorschemes.nord = {
      enable = true;
      settings = {
        borders = true;
        contrast = true;
      };
    };
    diagnostic.settings = {
      update_in_insert = true;
      severity_sort = true;
      signs = true;
      float = {
        source = "always";
        border = "rounded";
      };
      jump = {
        severity.__raw = "vim.diagnostic.severity.WARN";
      };
    };
    lsp = {
      luaConfig.post = ''
        local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
        for type, icon in pairs(signs) do
          local hl = "DiagnosticSign" .. type
          vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
        end
      '';
      inlayHints.enable = true;
      servers = {
        ansiblels = {
          enable = true;
          package = pkgs.callPackage ./ansible-language-server/package.nix { };
          config = {
            settings.ansible = {
              useFullyQualifiedCollectionNames = true;
            };
          };
        };
        bashls.enable = true;
        docker_language_server.enable = true;
        emmet_language_server.enable = true;
        eslint.enable = true;
        helm_ls.enable = true;
        jedi_language_server.enable = true;
        just.enable = true;
        jsonls.enable = true;
        markdown_oxide.enable = true;
        nginx_language_server.enable = true;
        nixd.enable = true;
        phan.enable = true;
        systemd_ls.enable = true;
        terraformls = {
          enable = true;
          config = {
            filetypes = [ "tf" ];
          };
        };
        #tofu_ls.enable = true;
        ts_ls.enable = true;
        yamlls.enable = true;
      };
    };
    plugins = {
      neo-tree = {
        settings = {
          close_if_last_window = true;
          default_component_configs = {
            name.use_filtered_colors = false;
            icon.use_filtered_colors = false;
            git_status = {
              symbols = {
                added = "";
                deleted = "";
                modified = "";
                renamed = "";
                untracked = "";
                ignored = "";
                unstaged = "";
                staged = "";
                conflict = "";
              };
            };
          };
          event_handlers = [
            {
              event = "file_open_requested";
              handler = {
                __raw = ''
                  function()
                    -- auto close
                    -- vim.cmd("Neotree close")
                    -- OR
                    require("neo-tree.command").execute({ action = "close" })
                  end
                '';
              };
            }
          ];
          filesystem.filtered_items = {
            visible = true;
            children_inherit_highlights = true;
          };
          window = {
            mappings = {
              "sf" = "close_window";
              "h" = "close_node";
              "s" = false;
              "f" = false;
              "l" = {
                __raw = ''
                    function(state)
                      local node = state.tree:get_node()
                      local path = node:get_id()
                      if node.type == 'directory' then
                          if not node:is_expanded() then
                              require('neo-tree.sources.filesystem').toggle_directory(state, node)
                          elseif node:has_children() then
                              require('neo-tree.ui.renderer').focus_node(state, node:get_child_ids()[1])
                          end
                      end
                      if node.type == 'file' then
                          require('neo-tree.utils').open_file(state, path)
                      end
                  end
                '';
              };
            };
          };
        };
        enable = true;
      };
      cmp-nvim-lsp.enable = true;
      cmp-nvim-lsp-signature-help.enable = true;
      cmp-path.enable = true;
      cmp-buffer.enable = true;
      cmp-git.enable = true;
      luasnip.enable = true;
      cmp-treesitter.enable = true;
      lspkind.enable = true;
      lspkind.cmp.enable = true;
      lsp-format.enable = true;
      cmp = {
        enable = true;
        settings = {
          snippet = {
            expand = ''
              function(args)
              require("luasnip").lsp_expand(args.body)
              end
            '';
          };
          autoEnableSources = true;
          mapping = {
            "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
            "<Down>" = "cmp.mapping.select_next_item()";
            "<Up>" = "cmp.mapping.select_prev_item()";
            "<C-E>" = "cmp.mapping.abort()";
            "<C-B>" = "cmp.mapping.scroll_docs(-4)";
            "<C-F>" = "cmp.mapping.scroll_docs(4)";
            "<C-Space>" = "cmp.mapping.complete()";
            "<CR>" = "cmp.mapping.confirm({ select = true })";
          };
          window = {
            completion = {
              border = "rounded";
              winhighlight = "Normal:Normal,FloatBorder:Normal,CursorLine:Visual,Search:None";
              zindex = 1001;
              scrolloff = 0;
              colOffset = 0;
              sidePadding = 1;
              scrollbar = true;
            };
          };
          sources = [
            { name = "path"; }
            {
              name = "nvim_lsp";
            }
            {
              name = "buffer";
            }
            {
              name = "luasnip";
              option = {
                show_autosnippets = true;
              };
            }
          ];
        };
      };
      lspconfig.enable = true;
      web-devicons = {
        enable = true;
      };
      project-nvim = {
        enable = true;
      };
      telescope = {
        keymaps = {
          ";f" = "find_files";
          ";b" = "file_browser";
          ";;" = "buffers";
          ";r" = "live_grep";
          ";d" = "diagnostics";
        };
        enable = true;
      };
      # Starting screen
      alpha = {
        enable = true;
        theme = "startify";
      };
      fugitive = {
        enable = true;
      };
      # Trim whitespace and lines
      trim = {
        enable = true;
        settings = {
          highlight = false;
        };
      };
      # Status line
      lualine = {
        enable = true;
        settings = {
          sections = {
            lualine_x = [
              "diagnostics"
              "encoding"
              "filetype"
            ];
          };
        };
      };
      indent-blankline = {
        enable = true;
        settings = {
          exclude.filetypes = [ "startify" ];
        };
      };
      barbar = {
        enable = true;
      };
      gitgutter = {
        enable = true;
      };
      vim-surround = {
        enable = true;
      };
      colorizer = {
        enable = true;
      };
      which-key = {
        enable = true;
      };
      illuminate = {
        enable = true;
      };
    };
    extraPlugins = with pkgs.vimPlugins; [
      ansible-vim
    ];
    opts = {
      number = true;
      syntax = "enable";
      fileencodings = "utf-8,sjis,euc-jp,latin";
      encoding = "utf-8";
      title = true;
      autoindent = true;
      background = "dark";
      backup = false;
      hlsearch = true;
      showcmd = true;
      cmdheight = 1;
      laststatus = 2;
      scrolloff = 10;
      expandtab = true;
      shell = "zsh";
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
        event = [ "CursorHold" ];
        callback = {
          __raw = "function() vim.diagnostic.open_float(nil, { focus = false }) end";
        };
      }
      {
        event = [
          "BufRead"
          "BufNewFile"
        ];
        pattern = [ "*.tf" ];
        command = "setfiletype tf";
      }

      {
        event = [ "InsertEnter" ];
        pattern = [ "*" ];
        command = "match EOLWS // | match EOLWSInsert /\\s\\+\\%#\\@<!$\\| \\+\\ze\\t/";
      }
      {
        event = [ "InsertLeave" ];
        pattern = [ "*" ];
        command = "match EOLWS // | match EOLWSInsert /\\s\\+\\%#\\@<!$\\| \\+\\ze\\t/";
      }
      {
        event = [
          "WinEnter"
          "BufWinEnter"
          "WinNew"
        ];
        pattern = [ "*" ];
        command = "match EOLWS /\\s\\+$\\| \\+\\ze\t/";
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
    highlightOverride = {
      NeoTreeDimText = {
        link = "Comment";
      };
      NeoTreeDotfile = {
        link = "Comment";
      };
      NeoTreeModified = {
        link = "NvimTreeGitDirty";
      };
      NeoTreeGitUntracked = {
        link = "NvimTreeGitNew";
      };
      NeoTreeGitUnstaged = {
        link = "NvimTreeGitDirty";
      };
      NeoTreeGitConflict = {
        link = "NvimTreeGitDeleted";
      };
    };
    globals = {
      suda_smart_edit = 1;
      "suda#nopass" = 1;
    };
    extraConfigLua = ''
      vim.api.nvim_set_hl(0, "MatchParen", { bg="#4c566a", fg="#88c0d0" })
      local _border = "rounded"

      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
        vim.lsp.handlers.hover, {
          border = _border
        }
      )

      vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
        vim.lsp.handlers.signature_help, {
          border = _border
        }
      )

      vim.diagnostic.config{
        float={border=_border}
      };

      require('lspconfig.ui.windows').default_options = {
        border = _border
      }
    '';
    extraConfigVim = ''
      set undofile
      set clipboard+=unnamedplus
    '';
    keymaps = [
      {
        mode = "n";
        key = "[d";
        action = {
          __raw = "function() vim.diagnostic.goto_prev({ float = true }) end";
        };
        options = {
          silent = true;
        };
      }
      {
        mode = "n";
        key = "]d";
        action = {
          __raw = "function() vim.diagnostic.goto_next({ float = true }) end";
        };
        options = {
          silent = true;
        };
      }

      {
        mode = "n";
        key = "sf";
        action = "<cmd>Neotree filesystem reveal left toggle<CR>";
        options = {
          silent = true;
        };
      }
      {
        mode = "n";
        key = ";j";
        action = "<Cmd>BufferPrevious<CR>";
        options = {
          silent = true;
        };
      }
      {
        mode = "n";
        key = ";k";
        action = "<Cmd>BufferNext<CR>";
        options = {
          silent = true;
        };
      }
      {
        mode = "n";
        key = ";x";
        action = "<Cmd>BufferClose<CR>";
        options = {
          silent = true;
        };
      }
      {
        mode = "n";
        key = ";xx";
        action = "<Cmd>BufferRestore<CR>";
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
    ];
  };
}
