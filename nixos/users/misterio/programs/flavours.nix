{
  # Data files
  xdg.dataFile = { "flavours/base16".source = "/dotfiles/flavours/base16"; };

  programs.flavours = {
    enable = true;

    settings = {
      item = [
        {
          file = "~/.config/alacritty/colors.yml";
          template = "alacritty";
          subtemplate = "default-256";
          rewrite = true;
        }
        {
          file = "~/.config/qutebrowser/colors.py";
          template = "qutebrowser";
          subtemplate = "colors";
          hook = "~/bin/reloadqb";
          rewrite = true;
        }
        {
          file = "~/.config/sway/colors";
          template = "sway";
          subtemplate = "colors";
          hook = "swaymsg reload";
          light = false;
          rewrite = true;
        }
        {
          file = "~/.config/nvim/colors/base16.vim";
          template = "vim";
          hook = "~/bin/reloadnvim";
          rewrite = true;
        }
        {
          file = "~/.config/zathura/colors";
          template = "zathura";
          rewrite = true;
        }
        {
          file = "~/.colors";
          template = "bash";
          rewrite = true;
        }
        {
          file = "~/.nix-wallpaper.svg";
          template = "svg-nix-wallpaper";
          rewrite = true;
        }
      ];
    };
  };
}
