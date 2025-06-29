{ pkgs, config, ... }:
{
  home.packages = [pkgs.jira-cli-go];
  home.persistence = {
    "/persist".directories = [".config/.jira"];
  };
}
