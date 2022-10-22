{ config, pkgs, lib, ... }: {
  home.sessionVariables.EDITOR = "nvim";

  programs.neovim = {
    enable = true;

    extraRuntime = {
      "colors/nix-${config.colorscheme.slug}.vim" = {
        text = import ./theme.nix config.colorscheme;
      };
    };

    extraConfig = {
      viml = /* vim */ ''
        "Use truecolor
        set termguicolors
        "Set colorscheme
        colorscheme nix-${config.colorscheme.slug}

        "Set fold level to highest in file
        "so everything starts out unfolded at just the right level
        augroup initial_fold
          autocmd!
          autocmd BufWinEnter * let &foldlevel = max(map(range(1, line('$')), 'foldlevel(v:val)'))
        augroup END

        "Tabs
        set tabstop=4 "4 char-wide tab
        set expandtab "Use spaces
        set softtabstop=0 "Use same length as 'tabstop'
        set shiftwidth=0 "Use same length as 'tabstop'
        "2 char-wide overrides
        augroup two_space_tab
          autocmd!
          autocmd FileType json,html,htmldjango,hamlet,nix,scss,typescript,php,haskell,terraform setlocal tabstop=2
        augroup END

        "Set tera to use htmldjango syntax
        augroup tera_htmldjango
          autocmd!
          autocmd BufRead,BufNewFile *.tera setfiletype htmldjango
        augroup END

        "Options when composing mutt mail
        augroup mail_settings
          autocmd FileType mail set noautoindent wrapmargin=0 textwidth=0 linebreak wrap formatoptions +=w
        augroup END

        "Fix nvim size according to terminal
        "(https://github.com/neovim/neovim/issues/11330)
        augroup fix_size
          autocmd VimEnter * silent exec "!kill -s SIGWINCH" getpid()
        augroup END

        "Line numbers
        set number relativenumber

        "Scroll up and down
        nmap <C-j> <C-e>
        nmap <C-k> <C-y>

        "Buffers
        nmap <C-l> :bnext<CR>
        nmap <C-h> :bprev<CR>
        nmap <C-q> :bdel<CR>

        "Loclist
        nmap <space>l :lwindow<cr>
        nmap [l :lprev<cr>
        nmap ]l :lnext<cr>

        nmap <space>L :lhistory<cr>
        nmap [L :lolder<cr>
        nmap ]L :lnewer<cr>

        "Quickfix
        nmap <space>q :cwindow<cr>
        nmap [q :cprev<cr>
        nmap ]q :cnext<cr>

        nmap <space>Q :chistory<cr>
        nmap [Q :colder<cr>
        nmap ]Q :cnewer<cr>

        "Grep (replace with ripgrep)
        nmap <space>g :silent grep<space>
        if executable('rg')
            set grepprg=rg\ --vimgrep
            set grepformat=%f:%l:%c:%m
        endif
      '';
      lua = /* lua */ ''
        -- LSP
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation" })
        vim.keymap.set("n", "<space>f", vim.lsp.buf.format, { desc = "Format code" })
        vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover Documentation" })

        -- Diagnostic
        vim.keymap.set("n", "<space>e", vim.diagnostic.open_float, { desc = "Floating diagnostic" })
        vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
        vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
        vim.keymap.set("n", "gl", vim.diagnostic.setloclist, { desc = "Diagnostics on loclist" })
        vim.keymap.set("n", "gq", vim.diagnostic.setqflist, { desc = "Diagnostics on quickfix" })

        function add_sign(name, text)
          vim.fn.sign_define(name, { text = text, texthl = name, numhl = name})
        end

        add_sign("DiagnosticSignError", " ")
        add_sign("DiagnosticSignWarn", " ")
        add_sign("DiagnosticSignHint", " ")
        add_sign("DiagnosticSignInfo", " ")
      '';
    };

    plugins = with pkgs.vimPlugins; [
      # Syntaxes
      rust-vim
      dart-vim-plugin
      plantuml-syntax
      vim-markdown
      vim-nix
      vim-toml
      vim-syntax-shakespeare
      gemini-vim-syntax
      kotlin-vim
      haskell-vim
      mermaid-vim
      pgsql-vim
      vim-terraform
      # Tree sitter
      (nvim-treesitter.withPlugins (_: pkgs.tree-sitter.allGrammars))

      # LSP
      {
        plugin = nvim-lspconfig;
        type = "lua";
        config = /* lua */ ''
          local lspconfig = require('lspconfig')

          function add_lsp(binary, server, options)
            if vim.fn.executable(binary) == 1 then server.setup{options} end
          end

          add_lsp("docker-langserver", lspconfig.dockerls, {})
          add_lsp("bash-language-server", lspconfig.bashls, {})
          add_lsp("clangd", lspconfig.clangd, {})
          add_lsp("rnix-lsp", lspconfig.rnix, {})
          add_lsp("pylsp", lspconfig.pylsp, {})
          add_lsp("dart", lspconfig.pylsp, {})
          add_lsp("haskell-language-server", lspconfig.hls, {})
          add_lsp("kotlin-language-server", lspconfig.kotlin_language_server, {})
          add_lsp("solargraph", lspconfig.solargraph, {})
          add_lsp("phpactor", lspconfig.phpactor, {})
          add_lsp("terraform-ls", lspconfig.terraformls, {})
          add_lsp("lua-language-server", lspconfig.sumneko_lua, {})
          add_lsp("jdtls", lspconfig.jdtls, {})
          add_lsp("texlab", lspconfig.texlab, {})
          add_lsp("gopls", lspconfig.gopls, {})
          add_lsp("jdt-language-server", lspconfig.jdtls, { cmd = { "jdt-language-server" }})
        '';
      }
      {
        plugin = rust-tools-nvim;
        type = "lua";
        config = /* lua */ ''
          local rust_tools = require('rust-tools')
          if vim.fn.executable("rust-analyzer") == 1 then
            rust_tools.setup{ tools = { autoSetHints = true } }
          end
        '';
      }

      # Completions
      cmp-nvim-lsp
      cmp-buffer
      lspkind-nvim
      {
        plugin = nvim-cmp;
        type = "lua";
        config = /* lua */ ''
          local cmp = require('cmp')

          cmp.setup{
            formatting = { format = require('lspkind').cmp_format() },
            -- Same keybinds as vim's vanilla completion
            mapping = {
              ['<C-n>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
              ['<C-p>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
              ['<C-e>'] = cmp.mapping.close(),
              ['<C-y>'] = cmp.mapping.confirm(),
            },
            sources = {
              { name='buffer', option = { get_bufnrs = vim.api.nvim_list_bufs } },
              { name='nvim_lsp' },
              { name='orgmode' },
            },
          }
        '';
      }

      # Org mode
      {
        plugin = orgmode;
        type = "lua";
        config = /* lua */ ''
          local orgmode = require('orgmode')
          orgmode.setup_ts_grammar()
          orgmode.setup{
            org_agenda_files = '~/Documents/Org/**/*',
            org_default_notes_file = '~/Documents/Org/todo/capture.org',
          }
        '';
      }

      # UI
      vim-illuminate
      vim-numbertoggle
      # vim-markology
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

      # Misc
      editorconfig-nvim
      vim-surround
      vim-fugitive
      {
        plugin = nvim-autopairs;
        type = "lua";
        config = /* lua */ ''
          require('nvim-autopairs').setup{}
        '';
      }
      {
        plugin = pkgs.writeTextDir "colors/nix-${config.colorscheme.slug}.vim"
          (import ./theme.nix config.colorscheme);
        config = /* vim */ ''
        '';
      }
    ];
  };

  xdg.configFile."nvim/init.lua".onChange = ''
    for server in $XDG_RUNTIME_DIR/nvim.*; do
      nvim --server $server --remote-send ':source $MYVIMRC<CR>' &
    done
  '';

  xdg.desktopEntries = {
    nvim = {
      name = "Neovim";
      genericName = "Text Editor";
      comment = "Edit text files";
      exec = "nvim %F";
      icon = "nvim";
      mimeType = [
        "text/english"
        "text/plain"
        "text/x-makefile"
        "text/x-c++hdr"
        "text/x-c++src"
        "text/x-chdr"
        "text/x-csrc"
        "text/x-java"
        "text/x-moc"
        "text/x-pascal"
        "text/x-tcl"
        "text/x-tex"
        "application/x-shellscript"
        "text/x-c"
        "text/x-c++"
      ];
      terminal = true;
      type = "Application";
      categories = [ "Utility" "TextEditor" ];
    };
  };
}
