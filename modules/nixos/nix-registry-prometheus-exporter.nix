# This pseudo exporter allows prometheus to scrap the machine's nix registry metadata
# This is useful, for example, to find out the nixpkgs rev.
{config, lib, pkgs, ...}: let
  cfg = config.services.prometheus.exporters.nix-registry;
  webroot = pkgs.writeTextDir "metrics/index.txt" (lib.concatMapAttrsStringSep "\n" (name: value:
    ''nix_registry{name="${name}",rev="${value.flake.rev or "dirty"}"} ${toString value.flake.lastModified}''
  ) config.nix.registry);
in {
  options.services.prometheus.exporters.nix-registry = {
    enable = lib.mkEnableOption "the prometheus nix-registry exporter";
    port = lib.mkOption {
      type = lib.types.port;
      default = 9172;
    };
    listenAddress = lib.mkOption {
      type = lib.types.str;
      default = "0.0.0.0";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services."prometheus-nix-registry-exporter" = {
      wantedBy = ["multi-user.target"];
      after = ["network.target"];
      serviceConfig = {
        Restart = "always";
        DynamicUser = true;
        ExecStart = "${lib.getExe pkgs.webfs} -F -p ${toString cfg.port} -i ${cfg.listenAddress} -f index.txt -r ${webroot}";
      };
    };
  };
}
