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
  services.postgresql = {
    enableTCPIP = true;
    ensureDatabases = [ "projeto_cloud" ];
    ensureUsers = [{
      name = "projeto_cloud";
      ensurePermissions = {
        "DATABASE projeto_cloud" = "ALL PRIVILEGES";
      };
    }];
  };
}
