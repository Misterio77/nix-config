{ 
  programs.alacritty = {
    enable = true;
    settings = {
      import = [
        "~/.config/alacritty/colors.yml"
      ];
      font = {
        size = 12.0;
        normal.family = "FiraCode Nerd Font";
      };
      window = {
        padding = {
          x = 20;
          y = 20;
        };
        dynamic_title = true;
      };
    };
  };
}
