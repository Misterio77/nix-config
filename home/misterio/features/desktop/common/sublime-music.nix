{pkgs, ...}: {
  home.packages = [pkgs.stable.sublime-music];
  home.persistence = {
    "/persist/home/misterio".directories = [".config/sublime-music"];
  };
}
