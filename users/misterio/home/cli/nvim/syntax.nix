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
    vim-syntax-shakespeare
    gemini-vim-syntax
    kotlin-vim
    haskell-vim
    mermaid-vim
    {
      plugin = pgsql-vim;
      config = "let g:sql_type_default = 'pgsql'";
    }
    {
      plugin = nvim-treesitter.withPlugins (_: pkgs.tree-sitter.allGrammars);
      config = /* vim */ ''
        lua require('nvim-treesitter.configs').setup{highlight={enable=true}}
        set foldmethod=expr
        set foldexpr=nvim_treesitter#foldexpr()
      '';
    }
  ];
}
