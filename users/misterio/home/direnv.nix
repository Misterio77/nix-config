{
  programs.direnv = {
    enable = true;
    nix-direnv = {
      enable = true;
      enableFlakes = true;
    };
  };

  home.persistence."/data/home/misterio".directories =
    [ ".local/share/direnv" ];
}
