{ pkgs, ... }: {
  programs.neovim.plugins = with pkgs.vimPlugins; [
    {
      plugin = rust-vim;
      config = "let g:rust_fold = 1";
    }
    dart-vim-plugin
    plantuml-syntax
    vim-markdown
    vim-nix
    vim-toml
    gemini-vim-syntax
    kotlin-vim
  ];
}
