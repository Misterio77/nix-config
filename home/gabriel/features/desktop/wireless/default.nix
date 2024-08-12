{ pkgs, ...}: let
  wpa_supplicant_gui = pkgs.symlinkJoin {
    inherit (pkgs.wpa_supplicant_gui) name meta;
    paths = [pkgs.wpa_supplicant_gui];
    nativeBuildInputs = [pkgs.makeWrapper];
    postFixup = ''
      wrapProgram $out/bin/wpa_gui --set QT_QPA_PLATFORMTHEME=gtk2
    '';
  };
in {
  home.packages = [wpa_supplicant_gui];
}
