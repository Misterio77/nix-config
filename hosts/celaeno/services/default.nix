{
  imports = [
    ../../common/optional/nginx.nix
    ../../common/optional/mysql.nix
    ../../common/optional/postgres.nix

    ./binary-cache.nix
    ./paste-misterio-me.nix
    ./disconic.nix
    ./gns3.nix

    ./hydra
  ];

  networking.firewall.allowedTCPPorts = [5432];
}
