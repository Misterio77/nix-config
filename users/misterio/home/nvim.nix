{ pkgs, ... }:

let
  vim-noctu = pkgs.vimUtils.buildVimPlugin {
    name = "vim-noctu";
    src = pkgs.fetchFromGitHub {
      owner = "noahfrederick";
      repo = "vim-noctu";
      rev = "de2ff9855bccd72cd9ff3082bc89e4a4f36ea4fe";
      sha256 = "sha256-fiMYfRlm/KiMQybL97RcWy3Y+0qim6kl3ZkBvCuv4ZM=";
    };
  };
  mermaid = pkgs.vimUtils.buildVimPlugin {
    name = "mermaid.vim";
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
      {
        plugin = ale;
        config = ''
          let g:ale_completion_enabled = 1
          let g:ale_linters = {"c": ["clang"], "rust": ["analyzer", "cargo"]}
          let g:ale_fixers = {"rust": ["rustfmt"], "sql": ["pgformatter"], "nix": ["nixfmt"]}
          let g:ale_rust_analyzer_config = {'checkOnSave': {'command': 'clippy', 'enable': v:true}}
        '';
      }
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
      auto-pairs
      dart-vim-plugin
      editorconfig-vim
      mermaid
      open-browser
      plantuml-syntax
      vim-markdown
      vim-nix
      vim-noctu
      vim-surround
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
      set tabstop=4 "How many spaces equals a tab
      set softtabstop=4 "How many columns when you hit tab
      set shiftwidth=4 "How many to indent with reindent ops
      set expandtab "Use spaces
      "set noexpandtab "Use tabs
      "Two spaces with html, typescript, scss, json, and nix
      autocmd FileType json,html,nix,scss,typescript setlocal ts=2 sts=2 sw=2

      "Options when composing mutt mail
      autocmd FileType mail set noautoindent wrapmargin=0 textwidth=0 linebreak wrap

      "Clipboard
      set clipboard=unnamedplus

      "Color scheme
      colorscheme noctu

      "Conceal
      set conceallevel=2

      "Line numbers
      augroup numbertoggle
        autocmd!
        autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
        autocmd BufLeave,FocusLost,InsertEnter   * set number norelativenumber
      augroup END

      "Fix nvim size according to terminal
      "(https://github.com/neovim/neovim/issues/11330)
      autocmd VimEnter * silent exec "!kill -s SIGWINCH" getpid()
    '';
  };
}
