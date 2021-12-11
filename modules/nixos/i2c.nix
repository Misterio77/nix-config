{ config, lib, pkgs, ... }:

let cfg = config.hardware.raspberry-pi."4".i2c-bcm2708;
in {
  options.hardware = {
    raspberry-pi."4".i2c-bcm2708 = {
      enable = lib.mkEnableOption ''
        Enable the Raspberry Pi 4 hardware i2c controller.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    hardware.deviceTree = {
      overlays = [{
        name = "i2c0";
        dtsText = ''
          	        /dts-v1/;
                          /plugin/;
                          /{
                              compatible = "raspberrypi,4-model-b";
                              fragment@1 {
                                  target = <&i2c1>;
                                  __overlay__ {
                                      status = "okay";
                                  };
                              };
                          };
                          '';
      }];
    };
  };
}
