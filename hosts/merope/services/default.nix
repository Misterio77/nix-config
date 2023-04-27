{
  imports = [
    ../../common/optional/nginx.nix

    ./deluge.nix
    ./files-server.nix
    ./navidrome.nix
  ];
}
