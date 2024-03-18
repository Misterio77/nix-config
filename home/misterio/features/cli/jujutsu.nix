{ config, ... }:
{
  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = config.programs.git.userName;
        email = config.programs.git.userEmail;
      };
    };
  };
}
