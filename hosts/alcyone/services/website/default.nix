{pkgs, ...}: let
  website = pkgs.inputs.website.default;
  pgpKey = ../../../../home/gabriel/pgp.asc;
  sshKey = ../../../../home/gabriel/ssh.pub;
  redir = {
    forceSSL = true;
    enableACME = true;
    locations."/".return = "302 https://m7.rs$request_uri";
  };
  days = n: (hours n) * 24;
  hours = n: (minutes n) * 60;
  minutes = n: n * 60;
in {
  imports = [
    ./themes.nix
    ./shortner.nix
  ];

  services.nginx.virtualHosts = {
    "m7.rs" = {
      forceSSL = true;
      enableACME = true;
      locations = {
        "/" = {
          root = "${website}/public";
          extraConfig = ''
            add_header Cache-Control "max-age=${toString (minutes 5)}, stale-while-revalidate=${toString (minutes 15)}";
          '';
        };
        "/assets/" = {
          root = "${website}/public";
          extraConfig = ''
            add_header Cache-Control "max-age=${toString (hours 1)}, stale-while-revalidate=${toString (days 30)}";
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
  };
}
