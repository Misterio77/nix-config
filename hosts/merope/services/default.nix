{
  imports = [
    ../../common/optional/nginx.nix
    ../../common/optional/mysql.nix
    ../../common/optional/postgres.nix

    ./deluge.nix
    ./files-server.nix
    ./navidrome.nix
  ];
}
