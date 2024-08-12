{pkgs, ...}: {
  qt = {
    enable = true;
    platformTheme = {
      name = "gtk3";
      package = [
        (pkgs.libsForQt5.qtstyleplugins.overrideAttrs (old: {
          patches = (old.patches or []) ++ [./qtstyleplugins-gtk3-key.patch];
          postInstall = (old.postInstall or "") + ''
            ln -s $out/${pkgs.qt5.qtbase.qtPluginPrefix}/platformthemes/libqgtk{2,3}.so
            ln -s $out/${pkgs.qt5.qtbase.qtPluginPrefix}/styles/libqgtk{2,3}style.so
          '';
        }))
        (pkgs.qt6.qtbase.override {
          # https://codereview.qt-project.org/c/qt/qtbase/+/547252
          patches = [./qtbase-gtk3-xdp.patch];
          qttranslations = null;
        })
      ];
    };
  };
}
