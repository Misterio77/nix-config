{ pkgs, lib, ... }: {
  home.packages = [ pkgs.lutris ];

  home.persistence = {
    "/persist/home/misterio" = {
      allowOther = true;
      directories = [
        {
          # Use symlink, as games may be IO-heavy
          directory = "Games/Lutris";
          method = "symlink";
        }
        ".config/lutris"
        ".local/share/lutris"
      ];
    };
  };
}
