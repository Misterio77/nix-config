{
  programs.git = {
    enable = true;
    aliases = { graph = "log --decorate --oneline --graph"; };
    userName = "Gabriel Fontes";
    userEmail = "eu@misterio.me";
    signing = {
      signByDefault = true;
      key = "CE707A2C17FAAC97907FF8EF2E54EA7BFE630916";
    };
    lfs = { enable = true; };
    ignores = [ ".direnv" ];
  };
}
