{ pkgs, config, ... }:

let

  kdeconnect-cli = "${pkgs.kdeconnect}/bin/kdeconnect-cli";
  fortune = "${pkgs.fortune}/bin/fortune";

  script-fortune = pkgs.writeShellScriptBin "fortune" ''
    ${kdeconnect-cli} -d $(${kdeconnect-cli} --list-available --id-only) --ping-msg "$(${fortune})"
  '';

in {
  services.kdeconnect = {
    enable = true;
    indicator = true;
  };

  xdg.configFile = {
    "kdeconnect-scripts/fortune.sh".source = "${script-fortune}/bin/fortune";
  };
}
