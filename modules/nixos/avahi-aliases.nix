{ config, lib, pkgs, ... }:

let cfg = config.services.avahi;
in {
  options.services.avahi = {
    subdomains = mkOption {
      type = type.listOf types.str;
      default = [];
      example = [ "example" "plex" ];
      description = ''
        Additional subdomains to broadcast.
      '';
    };
  };

  config = mkIf cfg.enable {
    systemd.services = builtins.listToAttrs lib.forEach cfg.subdomains (name: {
      name = "avahi-alias@${name}.${cfg.hostName}.${cfg.domainName}";
      value = {
        description = "Publish ${name}.${cfg.hostName}.${cfg.domainName} as alias for ${cfg.hostName}.${cfg.domainName} via mdns";
        requires = [ "avahi-daemon.service" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = ''
            ${pkgs.bash}/bin/bash -c "${pkgs.avahi}/bin/avahi-publish -a -R %I $(${avahi}/bin/avahi-resolve -4 -n ${cfg.hostName}.${cfg.domainName} | cut -f 2)"
          '';
        };
      };
    });
  };
}
