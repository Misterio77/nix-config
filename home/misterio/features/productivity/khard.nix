{pkgs, ...}: {
  home.packages = with pkgs; [khard];
  xdg.configFile."khard/khard.conf".text =
    /*
    toml
    */
    ''
      [addressbooks]
      [[contacts]]
      path = ~/Contacts/Main
    '';
}
