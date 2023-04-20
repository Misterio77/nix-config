{ pkgs, ... }: {
  programs.password-store = {
    enable = true;
    settings = { PASSWORD_STORE_DIR = "$HOME/.password-store"; };
    package = pkgs.pass.withExtensions (p: [ p.pass-otp ]);
  };

  services.pass-secret-service = {
    enable = true;
    storePath = null;
    # Use default ($HOME/.password-store)
    # Passing $HOME is buggy because systemd moment
  };

  home.persistence = {
    "/persist/home/misterio".directories = [ ".password-store" ];
  };
}
