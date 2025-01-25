{
  inputs,
  pkgs,
  ...
}: let
  mainPkg = flake: flakePkg flake "default";
  flakePkg = flake: name: flake.packages.${pkgs.system}.${name};
  minutes = n: toString (n * 60);
  days = n: toString (n * 60 * 60 * 24);
in {
  services.nginx.virtualHosts = {
    "gelos.club" = {
      forceSSL = true;
      enableACME = true;
      locations = {
        "/" = {
          root = "${mainPkg inputs.gelos-site}/public";
          extraConfig = ''
            add_header Cache-Control "max-age=${minutes 1}, stale-while-revalidate=${minutes 60}";
            # Antigo link de atas
            rewrite ^/([0-9]+)/([0-9]+)/([0-9]+)/ata\.html$ /reunioes/$1-$2-$3.html permanent;
          '';
        };
        "/assets/" = {
          root = "${mainPkg inputs.gelos-site}/public";
          extraConfig = ''
            add_header Cache-Control "max-age=${minutes 30}, stale-while-revalidate=${days 1}";
          '';
        };
        "=/identidade" = {
          return = "301 https://gelos.club/identidade/";
        };
        "/identidade/" = {
          alias = "${mainPkg inputs.gelos-identidade-visual}/";
        };

        # Alias para páginas pessoais
        "/~" = {
          extraConfig = ''
            rewrite ^/~([a-zA-Z]+)(index.html)?(\.html)?$ /membros/$1/ permanent;
          '';
        };

        # Permalinks mais curtinhos
        "=/problemas".return = "301 https://gelos.club/projetos/plantao.html#problemas-recorrentes";
        "=/pobremas".return = "301 https://gelos.club/projetos/plantao.html#problemas-recorrentes";
        "=/plantoes".return = "301 https://gelos.club/projetos/plantao.html";
        "=/plantao".return = "301 https://gelos.club/projetos/plantao.html";
        "=/fedi".return = "301 https://gelos.club/2024/08/20/fedi.html";
        # Eventos
        "=/debian-day".return = "301 https://gelos.club/2023/08/02/debian-day.html";
        "=/installfest-4".return = "301 https://gelos.club/2023/08/21/installfest-2023-2.html";
        "=/if4".return = "301 https://gelos.club/2023/08/21/installfest-2023-2.html";
        "=/installfest-5".return = "301 https://gelos.club/2024/03/01/installfest-2024-1.html";
        "=/if5".return = "301 https://gelos.club/2024/03/01/installfest-2024-1.html";
      };
    };

    "telegram.gelos.club" = {
      forceSSL = true;
      enableACME = true;
      locations."/".return = "302 https://t.me/gelos_geral";
    };
    "matrix.gelos.club" = {
      forceSSL = true;
      enableACME = true;
      locations."/".return = "302 https://matrix.to/#/#gelos:matrix.org";
    };
    "youtube.gelos.club" = {
      forceSSL = true;
      enableACME = true;
      locations."/".return = "302 https://www.youtube.com/@gelos3943";
    };
  };

  services.agate = {
    enable = true;
    hostnames = [ "gelos.club" "gelos.icmc.usp.br" ];
    contentDir = pkgs.writeTextDir "index.gmi" ''
      Site apenas disponível na web:
      => https://gelos.club
    '';
  };
  networking.firewall.allowedTCPPorts = [ 1965 ];
}
