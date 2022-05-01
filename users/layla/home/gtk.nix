{ config, pkgs, inputs, ... }:

let inherit (inputs.nix-colors.lib { inherit pkgs; }) gtkThemeFromScheme;
in rec {
  gtk = {
    enable = true;
    font = {
      name = "Fira Sans";
      size = 11;
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
