{ pkgs, host, ... }:

{
  home.packages = with pkgs; [ ranger ];
}
