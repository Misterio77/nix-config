{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [ pfetch ];
    sessionVariables.PF_INFO = "ascii title os kernel shell desktop term scheme palette";
  };
}
