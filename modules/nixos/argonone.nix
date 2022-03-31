{ config, lib, pkgs, ... }:

with lib;
let
  nur = import ../.. { inherit pkgs; };
  cfg = config.hardware.argonone;
in {
  options.hardware.argonone = {
    enable = mkEnableOption "the driver for Argon One Raspberry Pi case fan and power button";
    package = mkOption {
      type = types.package;
      default = nur.argononed;
      defaultText = "nur.argononed";
      description = ''
        The package implementing the Argon One driver

        Do note you need i2c enabled for this to work. Importing the rpi4 module from nixos-hardware should do the trick. 
      '';
    };
  };

  config = mkIf cfg.enable {
    hardware.i2c.enable = true;
    hardware.deviceTree.overlays = [
      {
        name = "argononed";
        dtboFile = "${cfg.package}/boot/overlays/argonone.dtbo";
      }
    ];
    environment.systemPackages = [ cfg.package ];
    systemd.services.argononed = {
      description = "Argon One Fan and Button Daemon Service";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "forking";
        ExecStart = "${cfg.package}/bin/argononed";
        PIDFile = "/run/argononed.pid";
        Restart = "on-failure";
      };
    };
  };

}
