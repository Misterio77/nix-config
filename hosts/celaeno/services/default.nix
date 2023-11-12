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
    authentication = ''
      host projeto_cloud projeto_cloud 0.0.0.0/0 md5
      host projeto_cloud projeto_cloud ::/0 md5
    '';
  };
}
