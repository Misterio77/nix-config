{pkgs, config, ...}: {
  home.packages = [pkgs.sublime-music];
  home.persistence = {
    "/persist".directories = [".config/sublime-music"];
  };
}
