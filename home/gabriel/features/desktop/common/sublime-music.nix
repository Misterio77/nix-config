{pkgs, config, ...}: {
  home.packages = [pkgs.stable.sublime-music];
  home.persistence = {
    "/persist/${config.home.homeDirectory}".directories = [".config/sublime-music"];
  };
}
