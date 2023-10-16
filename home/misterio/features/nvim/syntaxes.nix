{ pkgs, config, lib, ... }: let
  nvim-treesitter = pkgs.vimPlugins.nvim-treesitter.withAllGrammars.overrideAttrs (oldAttrs: {
    postPatch = "";
    src = pkgs.fetchFromGitHub {
      owner = "nvim-treesitter";
      repo = "nvim-treesitter";
      rev = "49e71322db582147ce8f4df1853d9dab08da0826";
      hash =  "sha256-i7/YKin/AuUgzKvGgAzNTEGXlrejtucJacFXh8t/uFs=";
    };
  });
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
        config = /* vim */ ''
          let g:vimtex_view_method = '${if config.programs.zathura.enable then "zathura" else "general"}'
        '';
      }

      # Tree sitter
      {
        plugin = nvim-treesitter;
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
