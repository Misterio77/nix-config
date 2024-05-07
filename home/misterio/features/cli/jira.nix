{ pkgs, ... }:
{
  home.packages = [pkgs.jira-cli-go];
  home.persistence = {
    "/persist/home/misterio".directories = [".config/.jira"];
  };
}
