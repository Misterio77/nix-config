{ pkgs, config, ... }:
{
  home.packages = [pkgs.jira-cli-go];
  home.persistence = {
    "/persist/${config.home.homeDirectory}".directories = [".config/.jira"];
  };
}
