# Something I did for a UI/UX class I took
# Decided to keep around to help out freshmen
{pkgs, ...}: let
  cincobola = pkgs.stdenv.mkDerivation {
    name = "cincobola";
    JEKYLL_ENV = "production";
    src = pkgs.fetchFromGitHub {
      owner = "misterio77";
      repo = "BSI-SCC0560";
      rev = "bd1dcc3";
      hash = "sha256-npPYxuZkqZWS0nRGc9IpTNviWzF5sFNUeVTdS6486lg=";
    };
    buildInputs = [pkgs.jekyll];
    buildPhase = ''
      jekyll build
    '';
    installPhase = ''
      cp -r _site -T $out
    '';
  };
  days = n: (hours n) * 24;
  hours = n: (minutes n) * 60;
  minutes = n: n * 60;
in {
  services.nginx.virtualHosts."cincobola.misterio.me" = {
    forceSSL = true;
    enableACME = true;
    locations = {
      "/" = {
        root = cincobola;
        tryFiles = "$uri $uri.html $uri/ =404";
        extraConfig = ''
          error_page 404 /404.html;
          add_header Cache-Control "max-age=${toString (minutes 15)}";
        '';
      };
      "/assets/" = {
        root = cincobola;
        extraConfig = ''
          add_header Cache-Control "max-age=${toString (days 30)}";
        '';
      };
    };
  };
}
