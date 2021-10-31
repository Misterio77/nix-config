{ pkgs, ... }:

let
  mermaid = pkgs.vimUtils.buildVimPlugin {
    pname = "mermaid.vim";
    version = "0.1";
    src = pkgs.fetchFromGitHub {
      owner = "mracos";
      repo = "mermaid.vim";
      rev = "5b61d983b979e95101bf85397510913376430739";
      sha256 = "sha256-mSr/UEdEGgi/otVQUTETKHykTZVP2+5kYWUuRJc0xZ4=";
    };
  };
in {
  home.sessionVariables = { EDITOR = "nvim"; };
  home.packages = with pkgs; [ neovim-remote ];

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

  programs.neovim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      # Colorscheme
      {
        plugin = vim-noctu;
        config = ''
          colorscheme noctu
        '';
      }
      # LSP and completion related
      lsp-colors-nvim
      {
        plugin = nvim-lspconfig;
        config = ''
          lua << EOF
          --Rust
          require'lspconfig'.rust_analyzer.setup{}
          --C/C++
          require'lspconfig'.clangd.setup{}
          --Nix
          require'lspconfig'.rnix.setup{}
          --JSON
          require'lspconfig'.jsonls.setup{}
          --SQL
          require'lspconfig'.sqls.setup{}
          --Python
          require'lspconfig'.pylsp.setup{}
          --Lua
          require'lspconfig'.sumneko_lua.setup{cmd = {"lua-language-server"}}
          EOF

          "Go to declaration/definition
          map gD       :lua vim.lsp.buf.declaration()<CR>
          map gd       :lua vim.lsp.buf.definition()<CR>
          "Diagnostics for current line
          map <space>e :lua vim.lsp.diagnostic.show_line_diagnostics()<CR>
          "Format code
          map <space>f :lua vim.lsp.buf.formatting()<CR>

          "Show tooltip info
          autocmd CursorHold <buf> :lua vim.lsp.buf.hover()<CR>
          map K :lua vim.lsp.buf.hover()<CR>
        '';
      }
      {
        plugin = nvim-cmp;
        config = ''
          "Completions from buffer and lsp
          lua require'cmp'.setup{sources={{name='nvim_lsp'},{name='buffer'}}}
        '';
      }
      cmp-nvim-lsp
      cmp-buffer
      {
        plugin = rust-tools-nvim;
        config = ''
          "Enable Rust typehints
          lua require('rust-tools').setup{tools={autoSetHints = true}}
        '';
      }
      # QOL
      {
        plugin = nerdtree;
        config = ''
          "Toggle nerdtree
          nmap <Bslash> :NERDTreeToggle<CR>
        '';
      }
      auto-pairs
      editorconfig-vim
      vim-numbertoggle
      vim-surround
      # Syntax
      {
        plugin = rust-vim;
        config = "let g:rust_fold = 1";
      }
      {
        plugin = vimtex;
        config = ''
          let g:vimtex_view_method = "zathura"
          let g:vimtex_view_automatic = 1
          let g:vimtex_compiler_latexmk = {'build_dir': 'build' }
        '';
      }
      dart-vim-plugin
      mermaid
      plantuml-syntax
      vim-markdown
      vim-nix
      vim-toml
    ];
    extraConfig = ''
      "Reload automatically
      set autoread
      au CursorHold,CursorHoldI * checktime

      "Folding
      set foldmethod=syntax
      "Set fold level to highest in file
      "so everything starts out unfolded at just the right level
      autocmd BufWinEnter * let &foldlevel = max(map(range(1, line('$')), 'foldlevel(v:val)'))

      "Tabs
      set ts=4 sts=4 sw=4 "4 char-wide tab
      autocmd FileType json,html,htmldjango,nix,scss,typescript setlocal ts=2 sts=2 sw=2 "2 char-wide overrides
      set expandtab "Use spaces

      "Options when composing mutt mail
      autocmd FileType mail set noautoindent wrapmargin=0 textwidth=0 linebreak wrap formatoptions +=w

      "Clipboard
      set clipboard=unnamedplus

      "Conceal
      set conceallevel=2

      "Fix nvim size according to terminal
      "(https://github.com/neovim/neovim/issues/11330)
      autocmd VimEnter * silent exec "!kill -s SIGWINCH" getpid()

      "Line numbers
      set number relativenumber
    '';
  };
}
