{ pkgs, ... }:
let
  git-m7-init = pkgs.writeShellScriptBin "git-m7-init" ''
    ${pkgs.openssh}/bin/ssh git@m7.rs << EOF
      git init --bare "$1.git"
      git -C "$1.git" branch -m main
    EOF
    git remote add origin git@m7.rs:"$1.git"
  '';
  git-m7-ls = pkgs.writeShellScriptBin "git-m7-ls" ''
    ${pkgs.openssh}/bin/ssh git@m7.rs << EOF
      ls
    EOF
  '';
in
{
  home.packages = [ git-m7-init git-m7-ls ];
  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;
    aliases = {
      pushall = "!git remote | xargs -L1 git push --all";
      graph = "log --decorate --oneline --graph";
      add-nowhitespace = "!git diff -U0 -w --no-color | !git apply --cached --ignore-whitespace --unidiff-zero -";
    };
    userName = "Gabriel Fontes";
    userEmail = "hi@m7.rs";
    extraConfig = {
      feature.manyFiles = true;
      init.defaultBranch = "main";
      url."https://github.com/".insteadOf = "git://github.com/";
    };
    lfs = { enable = true; };
    ignores = [ ".direnv" "result" ];
    signing = {
      signByDefault = true;
      key = "CE707A2C17FAAC97907FF8EF2E54EA7BFE630916";
    };
  };
}
