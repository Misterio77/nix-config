{
  programs.zathura = {
    enable = true;
    options = {
      selection-clipboard = "clipboard";
      font = "Fira Sans 12";
      recolor = true;
    };
    extraConfig = ''
      include colors
    '';
  };
}
