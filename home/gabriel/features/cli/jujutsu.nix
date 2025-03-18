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
        show-cryptographic-signatures = true;
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
              "Change summary:\n",
              indent("     ", diff.summary()),
              "Full change:\n",
              "ignore-rest\n",
            )),
            diff.git(),
          )
        '';
      };
    };
  };
}
