{ inputs, config, pkgs, ... }:

let
  vimThemeFromScheme = import ./theme.nix { inherit pkgs; };
in
{
  imports = [ ./ui.nix ./lsp.nix ./syntax.nix ];

  programs.neovim = {
    enable = true;
    extraConfig = /* vim */ ''
      "Use truecolor
      set termguicolors

      "Reload automatically
      set autoread
      au CursorHold,CursorHoldI * checktime

      "Set fold level to highest in file
      "so everything starts out unfolded at just the right level
      autocmd BufWinEnter * let &foldlevel = max(map(range(1, line('$')), 'foldlevel(v:val)'))

      "Tabs
      set ts=4 sts=4 sw=4 "4 char-wide tab
      autocmd FileType json,html,htmldjango,hamlet,nix,scss,typescript,php,haskell,tf setlocal ts=2 sts=2 sw=2 "2 char-wide overrides
      set expandtab "Use spaces

      "Set tera to use htmldjango syntax
      autocmd BufRead,BufNewFile *.tera setfiletype htmldjango

      "Options when composing mutt mail
      autocmd FileType mail set noautoindent wrapmargin=0 textwidth=0 linebreak wrap formatoptions +=w

      "Clipboard
      set clipboard=unnamedplus

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
      plenary-nvim
      editorconfig-vim
      vim-fugitive
      vim-matchup
      vim-surround
      {
        plugin = better-escape-nvim;
        config = /* lua */ ''
          lua require('better_escape').setup()
        '';
      }
      {
        plugin = nvim-autopairs;
        config = /* lua */ ''
          lua require('nvim-autopairs').setup{}
        '';
      }
      {
        plugin = vimThemeFromScheme { scheme = config.colorscheme; };
        config = /* vim */ ''
          colorscheme nix-${config.colorscheme.slug}
        '';
      }
      {
        plugin = vim-medieval;
        config = /* vim */ ''
          nmap <buffer> Z <Plug>(medieval-eval)
          let g:medieval_langs = ['haskell=runghc', 'sh']
        '';
      }
    ];
  };

  xdg.configFile."nvim/init.vim".onChange =
    let
      nvr = "${pkgs.neovim-remote}/bin/nvr";
    in
      /* sh */ ''
      ${nvr} --serverlist | while read server; do
        ${nvr} --servername $server --nostart -c ':so $MYVIMRC' & \
      done
    '';

  home.sessionVariables.EDITOR = "nvim";

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
