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
        behaviour = if gitCfg.commit.gpgSign then "own" else "never";
        key = gitCfg.user.signing.key;
      };
      template-aliases = {
        "gerrit_change_id(change_id)" = ''
          "Id0000000" ++ change_id.normal_hex()
        '';
      };
      templates = {
        draft_commit_description = ''
          concat(
            description,
            indent("JJ: ", concat(
              if(
                !description.contains("Change-Id: "),
                "Change-Id: " ++ gerrit_change_id(change_id) ++ "\n",
                "",
              ),
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
