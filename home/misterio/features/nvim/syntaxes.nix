{ pkgs, ... }: {
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

    # Org mode
    {
      plugin = orgmode;
      type = "lua";
      config = /* lua */ ''
        local orgmode = require('orgmode')
        orgmode.setup_ts_grammar()
        orgmode.setup{
          org_agenda_files = '~/Documents/Org/**/*',
          org_default_notes_file = '~/Documents/Org/todo/capture.org',
        }
      '';
    }
  ];
}
