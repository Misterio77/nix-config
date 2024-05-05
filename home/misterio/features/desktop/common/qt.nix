{
  pkgs,
  ...
}: {
  qt = {
    enable = true;
    platformTheme = {
      name = "gtk3";
    };
  };
}
