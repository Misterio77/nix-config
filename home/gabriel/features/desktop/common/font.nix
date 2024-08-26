{pkgs, ...}: {
  fontProfiles = {
    enable = true;
    monospace = {
      name = "FiraCode Nerd Font";
      package = pkgs.nerdfonts.override {fonts = ["FiraCode"];};
    };
    regular = {
      name = "Fira Sans";
      package = pkgs.fira;
    };
  };
}
