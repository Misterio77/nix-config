{ pkgs, config, ... }: {
  programs.neovim.plugins = with pkgs.vimPlugins; [
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
    vim-jsx-typescript

    {
      plugin = vimtex;
      config =
        let
          method =
            if config.programs.zathura.enable then "zathura" else "general";
        in
        ''
          let g:vimtex_view_method = '${method}'
        '';
    }
  ];
}
