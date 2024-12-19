{config, lib, ...}: {
  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = config.programs.git.userName;
        email = config.programs.git.userEmail;
      };
      ui = {
        pager = "less -FRX";
      };
      signing = let
        gitCfg = config.programs.git.extraConfig;
      in {
        backend = "gpg";
        sign-all = gitCfg.commit.gpgSign;
        key = gitCfg.user.signing.key;
      };
      templates = {
        draft_commit_description = ''
          concat(
            description,
            indent("JJ: ", concat(
              "\n",
              "Change summary:\n",
              indent("     ", diff.summary()),
              "\n",
              "Full change:\n",
              indent("     ", diff.git()),
            )),
          )
        '';
      };
    };
  };
}
