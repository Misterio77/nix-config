{ config, pkgs, lib, inputs, ... }:
let
  filterMap = filterf: mapf: xs:
    map mapf (builtins.filter filterf xs);
  getGrammarName = x:
    builtins.elemAt (builtins.match "tree-sitter-([a-z]*)" x) 0;
  hasGrammarName = x:
    null != (builtins.match "tree-sitter-([a-z]*)" x);
  treesitterGrammars =
    filterMap
      hasGrammarName
      getGrammarName
      (builtins.attrNames pkgs.tree-sitter-grammars);
in
{
  programs.neovim.plugins = with pkgs.vimPlugins; [
    # Tree sitter
    playground
    {
      plugin = nvim-treesitter.withPlugins (_: pkgs.tree-sitter.allGrammars);
      type = "lua";
      config = /* lua */ ''
        require('nvim-treesitter.configs').setup {
          highlight = {
            enable = true,
          },
          playground = {
            enable = true,
            keybindings = {
              toggle_query_editor = 'o',
              toggle_hl_groups = 'i',
              toggle_injected_languages = 't',
              toggle_anonymous_nodes = 'a',
              toggle_language_display = 'I',
              focus_language = 'f',
              unfocus_language = 'F',
              update = 'R',
              goto_node = '<cr>',
              show_help = '?',
            },
          },
        }
        -- Custom nix injection
        -- Placing in a dir does not seem to work
        vim.treesitter.query.set_query("nix", "injections", [[${builtins.concatStringsSep "\n"(
          builtins.map (lang: /* query */ ''
            ((((comment) @_language) .
              (indented_string_expression (string_fragment) @lua))
              (#match? @_language "\s*${lang}\s*"))

            '')
            treesitterGrammars
          )}
        ]])
      '';
    }
  ];
}
