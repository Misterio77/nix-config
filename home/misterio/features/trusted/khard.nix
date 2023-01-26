{ pkgs, ... }: {
  home.packages = with pkgs; [ khard ];
  xdg.configFile."khard/khard.conf".text = ''
    [addressbooks]
    [[contacts]]
    path = ~/Contacts/Main
  '';
}
