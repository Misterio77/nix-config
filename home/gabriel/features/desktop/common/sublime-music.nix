{pkgs, config, ...}: {
  home.packages = [pkgs.stable.sublime-music];
  home.persistence = {
    "/persist".directories = [".config/sublime-music"];
  };
}
