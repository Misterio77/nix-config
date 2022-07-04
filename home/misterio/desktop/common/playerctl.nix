{ pkgs, ... }:
{
  home.packages = with pkgs; [ playerctl lyrics ];
  services.playerctld = {
    enable = true;
  };
}
