{ pkgs, lib, ... }:
let
  pass-otp = pkgs.passExtensions.pass-otp.overrideAttrs (oa: {
    # https://github.com/tadfisher/pass-otp/pull/173
    patches = (oa.patches or [ ]) ++ [ ./pass-otp-fix-completion.patch ];
  });
in
{

  programs.password-store = {
    enable = true;
    settings = { PASSWORD_STORE_DIR = "$HOME/.password-store"; };
    package = pkgs.pass.withExtensions (_: [ pass-otp ]);
  };

  home.persistence = {
    "/persist/home/misterio".directories = [ ".password-store" ];
  };
}
