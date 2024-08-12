{pkgs, ...}: {
  qt = {
    enable = true;
    platformTheme = {
      name = "gtk3";
      package = [
        # QT 5
        (pkgs.libsForQt5.qtstyleplugins.overrideAttrs (old: {
          # Make qtstyleplugins' gtk2 platform theme activate if QT_QPA_PLATFORMTHEME=gtk3
          patches = (old.patches or []) ++ [./qtstyleplugins-gtk3-key.patch];
        }))
        # QT 6
        (pkgs.qt6.qtbase.override {
          # Make qtbase's gtk3 platform theme read dark/light status from xdp.
          # This is specially important as it's what qutebrowser reads to determine prefers-color-scheme.
          # https://codereview.qt-project.org/c/qt/qtbase/+/547252
          patches = [./qtbase-gtk3-xdp.patch];
          qttranslations = null;
        })
      ];
    };
  };
}
