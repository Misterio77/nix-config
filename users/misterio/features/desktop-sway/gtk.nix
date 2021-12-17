{ config, pkgs, inputs, ... }:

with inputs.nix-colors.lib { inherit pkgs; };

rec {
  gtk = {
    enable = true;
    font = {
      name = "Fira Sans";
      size = 12;
    };
    iconTheme = {
      name = "Papirus";
      package = pkgs.papirus-icon-theme;
    };
    theme = {
      name = "${config.colorscheme.slug}";
      package = gtkThemeFromScheme { scheme = config.colorscheme; };
    };
  };

  services.xsettingsd = {
    enable = true;
    settings = {
      "Net/ThemeName" = "${gtk.theme.name}";
      "Net/IconThemeName" = "${gtk.iconTheme.name}";
    };
  };
}
