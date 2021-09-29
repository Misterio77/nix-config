{ pkgs, host, ... }: {
  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;
    aliases = { graph = "log --decorate --oneline --graph"; };
    userName = "Gabriel Fontes";
    userEmail = "eu@misterio.me";
    signing = if host == "atlas" then {
      signByDefault = true;
      key = "CE707A2C17FAAC97907FF8EF2E54EA7BFE630916";
    } else {
      signByDefault = false;
      key = "";
    };
    extraConfig = { init = { defaultBranch = "main"; }; };
    lfs = { enable = true; };
    ignores = [ ".direnv" "result" ];
  };
}
