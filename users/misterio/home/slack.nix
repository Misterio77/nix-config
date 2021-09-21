{ pkgs, ... }:

{
  home.packages = with pkgs; [ slack ];
  home.persistence."/data/home/misterio".directories = [ ".config/Slack" ];
}
