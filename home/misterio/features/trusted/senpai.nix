{ config, pkgs, ... }:
let
  pass = "${config.programs.password-store.package}/bin/pass";
in
{
  home.packages = [ pkgs.senpai ];
  xdg.configFile."senpai/senpai.scfg".text = ''
    address chat.sr.ht
    nickname misterio
    password-cmd ${pass} chat.sr.ht/misterio
  '';
}
