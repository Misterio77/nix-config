{pkgs, ...}: {
  fontProfiles = {
    enable = true;
    monospace = {
      name = "FiraMono Nerd Font";
      package = pkgs.nerd-fonts.fira-mono;
    };
    regular = {
      name = "Fira Sans";
      package = pkgs.fira;
    };
  };
}
