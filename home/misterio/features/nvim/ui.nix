{pkgs, ...}: let
  gx-nvim = pkgs.vimUtils.buildVimPlugin {
    name = "gx-nvim";
    src = pkgs.fetchFromGitHub {
      owner = "chrishrb";
      repo = "gx.nvim";
      rev = "f29a87454b02880e0d76264c21be8316224a7395";
      hash = "sha256-QWJ/cPvSyMTJoWLg51BNFf9+/9i7G+nzennpHP/eQ4g=";
    };
  };
in {
  programs.neovim.plugins = with pkgs.vimPlugins; [
    {
      plugin = gx-nvim;
      type = "lua";
      config =
        /*
        lua
        */
        ''
          require('gx').setup{}
          vim.keymap.set({"n", "x"}, "gx", ":Browse<CR>", {
            desc = "Open the file under cursor with system app"
          })
        '';
    }
    # UI
    vim-illuminate
    vim-numbertoggle
    # vim-markology
    {
      plugin = vim-fugitive;
      type = "viml";
      config =
        /*
        vim
        */
        ''
          nmap <space>G :Git<CR>
        '';
    }
    {
      plugin = nvim-bqf;
      type = "lua";
      config =
        /*
        lua
        */
        ''
          require('bqf').setup{}
        '';
    }
    {
      plugin = alpha-nvim;
      type = "lua";
      config =
        /*
        lua
        */
        ''
          local alpha = require("alpha")
          local dashboard = require("alpha.themes.dashboard")

          dashboard.section.header.val = {
                "                                                     ",
                "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ",
                "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ",
                "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ",
                "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ",
                "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ",
                "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ",
                "                                                     ",
          }
          dashboard.section.header.opts.hl = "Title"

          dashboard.section.buttons.val = {
              dashboard.button( "n", "󰈔 New file" , ":enew<CR>"),
              dashboard.button( "e", " Explore", ":Explore<CR>"),
              dashboard.button( "g", " Git summary", ":Git | :only<CR>"),
              dashboard.button( "s", " Notes", ":e ~/Documents/Notes<CR>"),
              dashboard.button( "c", "  Nix config flake" , ":e ~/Documents/NixConfig/flake.nix<CR>"),
          }

          alpha.setup(dashboard.opts)
          vim.keymap.set("n", "<space>h", ":Alpha<CR>", { desc = "Open home dashboard" })
        '';
    }
    {
      plugin = bufferline-nvim;
      type = "lua";
      config =
        /*
        lua
        */
        ''
          require('bufferline').setup{}
        '';
    }
    {
      plugin = scope-nvim;
      type = "lua";
      config =
        /*
        lua
        */
        ''
          require('scope').setup{}
        '';
    }
    {
      plugin = which-key-nvim;
      type = "lua";
      config =
        /*
        lua
        */
        ''
          require('which-key').setup{}
        '';
    }
    {
      plugin = range-highlight-nvim;
      type = "lua";
      config =
        /*
        lua
        */
        ''
          require('range-highlight').setup{}
        '';
    }
    {
      plugin = indent-blankline-nvim;
      type = "lua";
      config =
        /*
        lua
        */
        ''
          require('ibl').setup{
            scope = { highlight = {"IndentBlankLine"} },
            indent = { highlight = {"IndentBlankLine"} },
          }
        '';
    }
    {
      plugin = nvim-web-devicons;
      type = "lua";
      config =
        /*
        lua
        */
        ''
          require('nvim-web-devicons').setup{}
        '';
    }
    {
      plugin = gitsigns-nvim;
      type = "lua";
      config =
        /*
        lua
        */
        ''
          require('gitsigns').setup{
            signs = {
              add = { text = '+' },
              change = { text = '~' },
              delete = { text = '_' },
              topdelete = { text = '‾' },
              changedelete = { text = '~' },
            },
          }
        '';
    }
    {
      plugin = nvim-colorizer-lua;
      type = "lua";
      config =
        /*
        lua
        */
        ''
          require('colorizer').setup{}
        '';
    }
    {
      plugin = fidget-nvim;
      type = "lua";
      config =
        /*
        lua
        */
        ''
          require('fidget').setup{
            text = {
              spinner = "dots",
            },
          }
        '';
    }
    {
      plugin = oil-nvim;
      type = "lua";
      config =
        /*
        lua
        */
        ''
          require('oil').setup{
            buf_options = {
              buflisted = true,
              bufhidden = "delete",
            },
            cleanup_delay_ms = false,
            use_default_keymaps = false,
            keymaps = {
              ["<CR>"] = "actions.select",
              ["-"] = "actions.parent",
              ["_"] = "actions.open_cwd",
              ["`"] = "actions.cd",
              ["~"] = "actions.tcd",
              ["gc"] = "actions.close",
              ["gr"] = "actions.refresh",
              ["gs"] = "actions.change_sort",
              ["gx"] = "actions.open_external",
              ["g."] = "actions.toggle_hidden",
              ["g\\"] = "actions.toggle_trash",
            },
          }
        '';
    }
  ];
}
