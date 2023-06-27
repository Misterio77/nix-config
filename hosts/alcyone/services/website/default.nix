{ inputs, pkgs, ... }:
let
  website = inputs.website.packages.${pkgs.system}.main;
  pgpKey = ../../../../home/misterio/pgp.asc;
  sshKey = ../../../../home/misterio/ssh.pub;
  redir = {
    forceSSL = true;
    enableACME = true;
    locations."/".return = "302 https://m7.rs$request_uri";
  };
  days = n: toString (n * 60 * 60 * 24);
in
{
  imports = [ ./themes.nix ];

  services.nginx.virtualHosts = {
    "m7.rs" = {
      forceSSL = true;
      enableACME = true;
      locations = {
        "/" = {
          root = "${website}/public";
        };
        "/assets/" = {
          root = "${website}/public";
          extraConfig = ''
            add_header Cache-Control "max-age=${days 30}";
          '';
        };

        "=/nix" = {
          # Script to download static nix
          alias = ./scripts/nix-installer.sh;
        };

        "=/setup-gpg" = {
          alias = ./scripts/setup-gpg.sh;
        };

        "=/7088C7421873E0DB97FF17C2245CAB70B4C225E9.asc".alias = pgpKey;
        "=/pgp.asc".alias = pgpKey;
        "=/pgp".alias = pgpKey;
        "=/ssh.pub".alias = sshKey;
        "=/ssh".alias = sshKey;
      };
    };
    "gsfontes.com" = redir;
    "misterio.me" = redir;
    "fontes.dev.br" = redir;
  };
}
