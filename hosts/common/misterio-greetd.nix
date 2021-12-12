{ config, pkgs, ... }: {
  services.greetd = {
    enable = true;
    settings = rec {
      initial_session = {
        command = "$SHELL";
        user = "misterio";
      };
      default_session = {
        command = "${pkgs.greetd.greetd}/bin/agreety --cmd $SHELL";
      };
    };
  };
}
