{ pkgs, lib, persistence, ... }:
let
  cgit = "${pkgs.semanticgit}";
in
{
  services = {
    nginx.virtualHosts = {
      "git.fontes.dev.br" = {
        forceSSL = true;
        enableACME = true;
        locations = {
          "=/cgit.css" = {
            alias = "${./cgit.css}";
          };
          "/assets" = {
            return = "301 https://fontes.dev.br$request_uri";
          };
          "/" = {
            root = "${cgit}/cgit";
            extraConfig = ''
              uwsgi_pass unix:/run/uwsgi/cgit.sock;
              include ${pkgs.nginx}/conf/uwsgi_params;
              uwsgi_modifier1 9;
            '';
          };
        };
      };
    };
    uwsgi.instance.vassals.cgit = {
      type = "normal";
      master = "true";
      socket = "/run/uwsgi/cgit.sock";
      procname-master = "uwsgi cgit";
      plugins = [ "cgi" ];
      cgi = "${cgit}/cgit/cgit.cgi";
    };
  };
  systemd.services.create-cgit-cache = {
    description = "Create cache directory for cgit";
    enable = true;
    wantedBy = [ "uwsgi.service" ];
    serviceConfig = {
      type = "oneshot";
    };
    script = ''
      mkdir -p /run/cgit
      chown -R nginx:nginx /run/cgit
    '';
  };
  environment = {
    persistence = lib.mkIf persistence {
      "/persist".directories = [
        "/srv/git"
      ];
    };
    etc."cgitrc".text = ''
      virtual-root=/

      cache-size=1000
      cache-root=/run/cgit

      root-title=Gabriel's Git
      root-desc=Source code for some of my projects
      logo-link=https://fontes.dev.br

      enable-http-clone=1
      noplainemail=1

      enable-git-config=1
      remove-suffix=1

      css=/cgit.css
      head-include=${./head.html}
      nav-include=${./nav.html}

      readme=:README.md
      readme=:README.rst

      source-filter=${cgit}/lib/cgit/filters/syntax-highlighting.py
      about-filter=${cgit}/lib/cgit/filters/about-formatting.sh

      scan-path=/srv/git/
      enable-git-config=1
    '';
  };
}
