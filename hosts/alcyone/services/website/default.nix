{ inputs, pkgs, ... }:
let
  website = inputs.website.packages.${pkgs.system}.main;
  pgpKey = ../../../../home/misterio/pgp.asc;
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
      default = true;
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
          # Sadly only works on linux
          alias = pkgs.writeText "nix" ''
            #/bin/sh

            arch="$(uname -m)"
            job="https://hydra.nixos.org/job/nix/master/buildStatic.$arch-linux/latest/download-by-type/file/binary-dist"
            echo "Downloading from: $job"

            mkdir -p "$HOME/.local/bin"
            curl -L "$job" -o "$HOME/.local/bin/nix"
            chmod +x "$HOME/.local/bin/nix"

            mkdir -p "$HOME/.config/nix"
            echo "experimental-features = nix-command flakes" >> "$HOME/.config/nix/nix.conf"
          '';
        };

        "=/7088C7421873E0DB97FF17C2245CAB70B4C225E9.asc".alias = pgpKey;
        "=/pgp.asc".alias = pgpKey;
        "=/pgp".alias = pgpKey;
      };
    };
    "gsfontes.com" = redir;
    "misterio.me" = redir;
    "fontes.dev.br" = redir;
  };
}
