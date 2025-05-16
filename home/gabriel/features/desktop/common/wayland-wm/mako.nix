{config, ...}: let
  inherit (config.colorscheme) colors mode;
in {
  services.mako = {
    enable = true;
    settings = {
      icon-path =
        if mode == "dark"
        then "${config.gtk.iconTheme.package}/share/icons/Papirus-Dark"
        else "${config.gtk.iconTheme.package}/share/icons/Papirus-Light";
      font = "${config.fontProfiles.regular.name} ${toString config.fontProfiles.regular.size}";
      padding = "10,20";
      anchor = "top-center";
      width = 400;
      height = 150;
      border-size = 2;
      default-timeout = 12000;
      background-color = "${colors.surface}dd";
      border-color = "${colors.secondary}dd";
      text-color = "${colors.on_surface}dd";
      layer = "overlay";
      max-history = 50;
    };
  };
}
