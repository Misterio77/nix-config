{
  imports = [
    ../../common/optional/nginx.nix
    ../../common/optional/mysql.nix
    ../../common/optional/postgres.nix

    ./binary-cache.nix
    ./paste-misterio-me.nix
    ./disconic.nix

    ./hydra
    ./minecraft
  ];

  networking.firewall.allowedTCPPorts = [ 5432 ];
}
