{
  pkgs,
  config,
  lib,
  ...
}: let
  jj-vim = pkgs.writeTextDir "syntax/jj.vim" (lib.readFile ./jj.vim);
in {
  programs.neovim = {
    extraConfig = lib.mkAfter /* vim */ ''
      function! SetCustomKeywords()
        syn match Todo  /TODO/
        syn match Done  /DONE/
        syn match Start /START/
        syn match End   /END/
      endfunction

      autocmd Syntax * call SetCustomKeywords()
    '';
    plugins = with pkgs.vimPlugins; [
      jj-vim
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
        config = let
          viewMethod =
            if config.programs.zathura.enable
            then "zathura"
            else "general";
        in
          /*
          vim
          */
          ''
            let g:vimtex_view_method = '${viewMethod}'
            "Don't open automatically
            let g:vimtex_quickfix_mode = 0
          '';
      }

      # Tree sitter
      {
        plugin = nvim-treesitter.withAllGrammars;
        type = "lua";
        config =
          /*
          lua
          */
          ''
            require('nvim-treesitter.configs').setup{
              highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
                disable = function(lang, bufnr)
                  return vim.fn.getfsize(vim.api.nvim_buf_get_name(bufnr)) > 1048576
                end
              },
            }
          '';
      }
    ];
  };
}
