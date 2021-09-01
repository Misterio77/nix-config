{ pkgs, ... }: {

  programs.password-store = {
    enable = true;
    package = pkgs.pass.withExtensions (exts: [ exts.pass-otp ]);
  };

  home.persistence."/data/home/misterio".directories = [ ".local/share/password-store" ];
}
