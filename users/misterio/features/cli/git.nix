{ pkgs, ... }: {
  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;
    aliases = {
      pushall = "!git remote | xargs -L1 git push --all";
      graph = "log --decorate --oneline --graph";
    };
    userName = "Gabriel Fontes";
    userEmail = "eu@misterio.me";
    extraConfig = { init = { defaultBranch = "main"; }; };
    lfs = { enable = true; };
    ignores = [ ".direnv" "result" ];
  };
}
