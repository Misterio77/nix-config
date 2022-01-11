{ inputs, config, pkgs, ... }:

with inputs.nix-colors.lib { inherit pkgs; };

{
  imports = [ ./ui.nix ./lsp.nix ./syntax.nix ];

  programs.neovim = {
    enable = true;
    extraConfig = ''
      "Use truecolor
      set termguicolors

      "Reload automatically
      set autoread
      au CursorHold,CursorHoldI * checktime

      "Folding
      set foldmethod=syntax
      "Set fold level to highest in file
      "so everything starts out unfolded at just the right level
      autocmd BufWinEnter * let &foldlevel = max(map(range(1, line('$')), 'foldlevel(v:val)'))

      "Tabs
      set ts=4 sts=4 sw=4 "4 char-wide tab
      autocmd FileType json,html,htmldjango,nix,scss,typescript,php,haskell setlocal ts=2 sts=2 sw=2 "2 char-wide overrides
      set expandtab "Use spaces

      "Set tera to use htmldjango syntax
      autocmd BufRead,BufNewFile *.tera setfiletype htmldjango

      "Options when composing mutt mail
      autocmd FileType mail set noautoindent wrapmargin=0 textwidth=0 linebreak wrap formatoptions +=w

      "Clipboard
      set clipboard=unnamedplus

      "Conceal
      set conceallevel=2

      "Fix nvim size according to terminal
      "(https://github.com/neovim/neovim/issues/11330)
      autocmd VimEnter * silent exec "!kill -s SIGWINCH" getpid()

      "Line numbers
      set number relativenumber

      "Scroll up and down
      nmap <C-j> <C-e>
      nmap <C-k> <C-y>
    '';
    plugins = with pkgs.vimPlugins; [
      editorconfig-vim
      vim-fugitive
      vim-illuminate
      vim-matchup
      vim-numbertoggle
      vim-surround
      {
        plugin = better-escape-nvim;
        config = "lua require('better_escape').setup()";
      }
      {
        plugin = range-highlight-nvim;
        config = "lua require('range-highlight').setup{}";
      }
      {
        plugin = nvim-autopairs;
        config = "lua require('nvim-autopairs').setup{}";
      }
      {
        plugin = which-key-nvim;
        config = "lua require('which-key').setup{}";
      }
      {
        plugin = vimThemeFromScheme { scheme = config.colorscheme; };
        config = "colorscheme nix-${config.colorscheme.slug}";
      }
    ];
  };

  xdg.configFile."nvim/init.vim".onChange = let
    nvr = "${pkgs.neovim-remote}/bin/nvr";
  in ''
    ${nvr} --serverlist | while read server; do
      ${nvr} --servername $server --nostart -c ':so $MYVIMRC' & \
    done
  '';

  home.sessionVariables = { EDITOR = "nvim"; };

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
}
