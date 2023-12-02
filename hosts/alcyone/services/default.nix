{
  imports = [
    ../../common/optional/nginx.nix
    ../../common/optional/mysql.nix
    ../../common/optional/postgres.nix

    ./firefly.nix
    ./cincobola.nix
    ./files-server.nix
    ./git-remote.nix
    ./headscale.nix
    ./mail.nix
    ./prometheus.nix
    ./radicale.nix

    ./cgit
    ./website
  ];
}
