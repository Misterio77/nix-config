{config, lib, ...}: {
  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = config.programs.git.userName;
        email = config.programs.git.userEmail;
      };
      ui = {
        diff-editor = lib.mkIf config.programs.neovim.enable [
          "nvim" "-c" "DiffEditor $left $right $output"
        ];
        pager = "less -FRX";
      };
      signing = let
        gitCfg = config.programs.git.extraConfig;
      in {
        backend = "gpg";
        sign-all = gitCfg.commit.gpgSign;
        key = gitCfg.user.signing.key;
      };
    };
  };
}
