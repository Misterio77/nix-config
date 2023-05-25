{ pkgs, ... }: {
  programs.neovim.plugins = with pkgs.vimPlugins; [
    # UI
    vim-illuminate
    vim-numbertoggle
    # vim-markology
    {
      plugin = vim-fugitive;
      type = "viml";
      config = /* vim */ ''
        nmap <space>G :Git<CR>
      '';
    }
    {
      plugin = nvim-bqf;
      type = "lua";
      config = /* lua * */ ''
        require('bqf').setup{}
      '';
    }
    {
      plugin = alpha-nvim;
      type = "lua";
      config = /* lua */ ''
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
            dashboard.button( "n", " New file" , ":enew<CR>"),
            dashboard.button( "e", " Explore", ":Explore<CR>"),
            dashboard.button( "g", " Git summary", ":Git | :only<CR>"),
            dashboard.button( "c", "  Nix config flake" , ":cd ~/Documents/NixConfig | :e flake.nix<CR>"),
            dashboard.button( "q", "  Quit nvim", ":qa<CR>"),
        }

        alpha.setup(dashboard.opts)
        vim.keymap.set("n", "<space>a", ":Alpha<CR>", { desc = "Open alpha dashboard" })
      '';
    }
    {
      plugin = bufferline-nvim;
      type = "lua";
      config = /* lua */ ''
        require('bufferline').setup{}
      '';
    }
    {
      plugin = scope-nvim;
      type = "lua";
      config = /* lua */ ''
        require('scope').setup{}
      '';
    }
    {
      plugin = which-key-nvim;
      type = "lua";
      config = /* lua */ ''
        require('which-key').setup{}
      '';
    }
    {
      plugin = range-highlight-nvim;
      type = "lua";
      config = /* lua */ ''
        require('range-highlight').setup{}
      '';
    }
    {
      plugin = indent-blankline-nvim;
      type = "lua";
      config = /* lua */ ''
        require('indent_blankline').setup{char_highlight_list={'IndentBlankLine'}}
      '';
    }
    {
      plugin = nvim-web-devicons;
      type = "lua";
      config = /* lua */ ''
        require('nvim-web-devicons').setup{}
      '';
    }
    {
      plugin = gitsigns-nvim;
      type = "lua";
      config = /* lua */ ''
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
      config = /* lua */ ''
        require('colorizer').setup{}
      '';
    }
    {
      plugin = fidget-nvim;
      type = "lua";
      config = /* lua */ ''
        require('fidget').setup{
          text = {
            spinner = "dots",
          },
        }
      '';
    }
  ];
}
