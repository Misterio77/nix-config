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
in
{
  imports = [ ./nvim-theme.nix ];

  programs.neovim = {
    enable = true;
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

      "Scroll up and down
      nmap <C-j> <C-e>
      nmap <C-k> <C-y>
    '';
    plugins = with pkgs.vimPlugins; [

      # LSP
      {
        plugin = nvim-lspconfig;
        config = ''
          lua << EOF
            local lspconfig = require('lspconfig')
            lspconfig.rust_analyzer.setup{} -- Rust
            lspconfig.clangd.setup{} -- C/C++
            lspconfig.rnix.setup{} -- Nix
            lspconfig.jsonls.setup{} -- JSON
            lspconfig.sqls.setup{cmd = {"sqls", "-config", "sqls.yml"}} -- SQL
            lspconfig.pylsp.setup{} -- Python
            lspconfig.sumneko_lua.setup{cmd = {"lua-language-server"}} -- Lua
          EOF

          nmap gD       :lua vim.lsp.buf.declaration()<CR>
          nmap gd       :lua vim.lsp.buf.definition()<CR>
          nmap <space>e :lua vim.lsp.diagnostic.show_line_diagnostics()<CR>
          nmap <space>f :lua vim.lsp.buf.formatting()<CR>

          autocmd CursorHold <buf> :lua vim.lsp.buf.hover()<CR>
          nmap K :lua vim.lsp.buf.hover()<CR>
        '';
      }
      { plugin = rust-tools-nvim; config = "lua require('rust-tools').setup{tools={autoSetHints = true}}"; }

      # Completions
      cmp-nvim-lsp
      cmp-buffer
      lspkind-nvim
      {
        plugin = nvim-cmp;
        config = ''
          lua << EOF
            local cmp = require('cmp')
            local lspkind = require('lspkind')
            cmp.setup{
              formatting = {
                format = lspkind.cmp_format()
              },
              mapping = {
                ['<C-n>'] = cmp.mapping.select_next_item({
                  behavior = cmp.SelectBehavior.Insert }
                ),
                ['<C-m>'] = cmp.mapping.select_prev_item({
                  behavior = cmp.SelectBehavior.Insert }
                ),
                ['<C-e>'] = cmp.mapping.close(),
              },
              sources = {
                { name='nvim_lsp' },
                { name='buffer' },
              },
            }
          EOF
        '';
      }

      # QOL
      editorconfig-vim
      vim-numbertoggle
      vim-surround
      vim-matchup
      { plugin = nvim-autopairs; config = "lua require('nvim-autopairs').setup{}"; }
      { plugin = better-escape-nvim; config = "lua require('better_escape').setup()"; }
      { plugin = bufdelete-nvim; config = "nmap <C-q> :Bdelete<CR>"; }

      # UI
      { plugin = nvim-web-devicons; config = "lua require('nvim-web-devicons').setup{}"; }
      { plugin = nvim-colorizer-lua; config = "lua require('colorizer').setup()"; }
      { plugin = gitsigns-nvim; config = "lua require('gitsigns').setup()"; }
      {
        plugin = bufferline-nvim;
        config = ''
          lua require('bufferline').setup{}
          nmap <C-h> :BufferLineCyclePrev<CR>
          nmap <C-l> :BufferLineCycleNext<CR>
        '';
      }
      {
        plugin = nvim-tree-lua;
        config = ''
          lua require('nvim-tree').setup{}
          nmap <C-p> :NvimTreeToggle<CR>
        '';
      }
      {
        plugin = feline-nvim;
        config = ''
          lua << EOF
          local components = {
            active = {},
            inactive = {},
          }
          require('feline').setup()
          EOF
        '';
      }

      # Syntaxes
      { plugin = rust-vim; config = "let g:rust_fold = 1"; }
      dart-vim-plugin
      mermaid
      plantuml-syntax
      vim-markdown
      vim-nix
      vim-toml
    ];
  };

  home.sessionVariables = { EDITOR = "nvim"; };

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
