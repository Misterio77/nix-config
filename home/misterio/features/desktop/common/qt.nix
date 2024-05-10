{pkgs, ...}: {
  qt = {
    enable = true;
    platformTheme = {
      name = "gtk3";
      package = pkgs.qt6.qtbase.override {
        # https://codereview.qt-project.org/c/qt/qtbase/+/547252
        patches = [./qtbase-gtk3-xdp.patch];
        qttranslations = null;
      };
    };
  };
}
