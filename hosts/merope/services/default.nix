{
  imports = [
    ../../common/optional/nginx.nix
    ../../common/optional/mysql.nix
    ../../common/optional/postgres.nix

    ./media.nix
    ./deluge.nix
    ./files-server.nix
  ];
}
