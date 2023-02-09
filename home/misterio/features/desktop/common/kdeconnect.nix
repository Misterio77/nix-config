{ pkgs, lib, ... }:

let

  kdeconnect-cli = "${pkgs.plasma5Packages.kdeconnect-kde}/bin/kdeconnect-cli";
  fortune = "${pkgs.fortune}/bin/fortune";

  script-fortune = pkgs.writeShellScriptBin "fortune" ''
    ${kdeconnect-cli} -d $(${kdeconnect-cli} --list-available --id-only) --ping-msg "$(${fortune})"
  '';

in
{
  # Hide all .desktop, except for org.kde.kdeconnect.settings
  xdg.desktopEntries = {
    "org.kde.kdeconnect.sms" = {
      exec = "";
      name = "KDE Connect SMS";
      settings.NoDisplay = "true";
    };
    "org.kde.kdeconnect.nonplasma" = {
      exec = "";
      name = "KDE Connect Indicator";
      settings.NoDisplay = "true";
    };
    "org.kde.kdeconnect.app" = {
      exec = "";
      name = "KDE Connect";
      settings.NoDisplay = "true";
    };
  };

  services.kdeconnect = {
    enable = true;
    indicator = true;

  };

  xdg.configFile = {
    "kdeconnect-scripts/fortune.sh".source = "${script-fortune}/bin/fortune";
  };

  home.persistence = {
    "/persist/home/misterio".directories = [ ".config/kdeconnect" ];
  };
}
