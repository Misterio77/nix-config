{ pkgs, config, lib, ... }: {
  programs.neovim = {
    extraConfig = /* vim */ lib.mkAfter ''
      function SetCustomKeywords()
        syn match Todo  /TODO/
        syn match Done  /DONE/
        syn match Start /START/
        syn match End   /END/
      endfunction

      autocmd Syntax * call SetCustomKeywords()
    '';
    plugins = with pkgs.vimPlugins; [
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
      vim-caddyfile

      {
        plugin = vimtex;
        config =
          let
            method =
              if config.programs.zathura.enable
              then "zathura"
              else "general";
          in
          ''
            let g:vimtex_view_method = '${method}'
          '';
      }

      # Tree sitter
      {
        plugin = nvim-treesitter.withAllGrammars;
        type = "lua";
        config = /* lua */ ''
          require('nvim-treesitter.configs').setup{
            highlight = {
              enable = true,
              additional_vim_regex_highlighting = false,
            },
          }
        '';
      }
    ];
  };
}
