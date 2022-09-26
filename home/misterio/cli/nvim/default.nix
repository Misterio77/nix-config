{ config, pkgs, lib, ... }: {
  imports = [ ./lsp.nix ];

  home = {
    sessionVariables.EDITOR = "nvim";
    preferredApps.editor = {
      cmd = config.home.preferredApps.terminal.cmd-spawn "nvim";
    };
  };

  programs.neovim = {
    enable = true;

    extraRuntime = {
      "colors/nix-${config.colorscheme.slug}.vim" = {
        text = import ./theme.nix config.colorscheme;
      };
    };

    extraConfig.viml = /* vim */ ''
      "Use truecolor
      set termguicolors
      "Set colorscheme
      colorscheme nix-${config.colorscheme.slug}

      "Set fold level to highest in file
      "so everything starts out unfolded at just the right level
      autocmd BufWinEnter * let &foldlevel = max(map(range(1, line('$')), 'foldlevel(v:val)'))

      "Tabs
      set tabstop=4 "4 char-wide tab
      set expandtab "Use spaces
      set softtabstop=0 "Use same length as 'tabstop'
      set shiftwidth=0 "Use same length as 'tabstop'
      "2 char-wide overrides
      autocmd FileType json,html,htmldjango,hamlet,nix,scss,typescript,php,haskell,terraform setlocal tabstop=2

      "Set tera to use htmldjango syntax
      autocmd BufRead,BufNewFile *.tera setfiletype htmldjango

      "Options when composing mutt mail
      autocmd FileType mail set noautoindent wrapmargin=0 textwidth=0 linebreak wrap formatoptions +=w

      "Fix nvim size according to terminal
      "(https://github.com/neovim/neovim/issues/11330)
      autocmd VimEnter * silent exec "!kill -s SIGWINCH" getpid()

      "Line numbers
      set number relativenumber

      "Scroll up and down
      nmap <C-j> <C-e>
      nmap <C-k> <C-y>

      "Buffers
      set wildcharm=<C-Z>
      nmap <space>b :buffer <C-Z>
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

      "Use ugrep as :grep
      if executable('ugrep')
          set grepprg=ugrep\ -RInk\ -j\ -u\ --tabs=1\ --ignore-files
          set grepformat=%f:%l:%c:%m,%f+%l+%c+%m,%-G%f\\\|%l\\\|%c\\\|%m
      endif
    '';

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
      editorconfig-vim
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
