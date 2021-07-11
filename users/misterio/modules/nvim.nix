{ pkgs, ... }:

let
  vim-dim = pkgs.vimUtils.buildVimPlugin {
      name = "vim-dim";
      src = pkgs.fetchFromGitHub {
        owner = "jeffkreeftmeijer";
        repo = "vim-dim";
        rev = "8320a40f12cf89295afc4f13eb10159f29c43777";
        sha256 = "0mnwr4kxhng4mzds8l72s5km1qww4bifn5pds68c7zzyyy17ffxh";
      };
  };
in {
  home.sessionVariables = { EDITOR = "nvim"; };
  home.packages = with pkgs; [
    neovim-remote
  ];

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
      vim-dim
      auto-pairs
      vim-surround
      vim-markdown
      {
        plugin = rust-vim;
        config = "let g:rust_fold = 1";
      }
      {
        plugin = vimtex;
        config = ''
          let g:vimtex_view_method = "zathura"
          let g:vimtex_view_automatic = 0
        '';
        #let g:vimtex_compiler_latexmk = {'options': ['-pdf','-shell-escape', '-verbose', '-file-line-error', '-synctex=1', '-interaction=nonstopmode',]}
      }
      vim-toml
      vim-nix
      rust-vim
      dart-vim-plugin
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
      "Two spaces with html and nix
      autocmd FileType html,nix setlocal ts=2 sts=2 sw=2

      "Clipboard
      set clipboard=unnamedplus

      "Color scheme
      colorscheme dim

      "Conceal
      set conceallevel=2

      "Line numbers
      augroup numbertoggle
        autocmd!
        autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
        autocmd BufLeave,FocusLost,InsertEnter   * set number norelativenumber
      augroup END
    '';
  };
}
