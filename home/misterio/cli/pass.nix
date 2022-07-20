{ pkgs, persistence, lib, ... }: {

  programs.password-store = {
    enable = true;
    settings = { PASSWORD_STORE_DIR = "$HOME/.password-store"; };
    package = pkgs.pass.withExtensions (exts: [ exts.pass-otp ]);
  };

  home.persistence = lib.mkIf persistence {
    "/persist/home/misterio".directories = [ ".password-store" ];
  };
}
