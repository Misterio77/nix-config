{ pkgs, ... }: {
  home.packages = with pkgs; [
    fira
    fira-code
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
  ];
  fonts.fontconfig.enable = true;
}
