{ config, options, lib, pkgs, ... }:
with lib;

let cfg = config.services.rgbdaemon;

in {
  # TODO make more configurable
  options = {
    services.rgbdaemon = {
      enable = mkEnableOption ''
        Misterio Rgbdaemon
      '';
    };
  };
  config = mkIf cfg.enable {
    systemd.user.services.rgbdaemon = {
      Unit = { Description = "Misterio RGB Daemon"; };
      Service = {
        # TODO turn daemon into a package
        ExecStart = "/home/misterio/bin/rgbdaemon";
        ExecStopPost = "/home/misterio/bin/rgboff";
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
        Restart = "on-failure";
      };
      Install = { WantedBy = [ "sway-session.target" ]; };
    };
  };
}
