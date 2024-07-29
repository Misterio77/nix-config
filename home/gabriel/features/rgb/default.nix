{config, lib, ...}: let
  inherit (config.colorscheme) colors;
in {
  systemd.user.services.rgb = {
    Unit.Description = "Set RGB colors to match scheme. Requires openrgb.";
    Service = {
      Type = "oneshot";
      ExecStart = "openrgb --client --color ${lib.removePrefix "#" colors.surface} --mode direct";
      ExecStop = "openrgb --client --color 000000 --mode direct";
      RemainAfterExit = true;
      ExecCondition = "systemctl is-active openrgb";
    };
  };
}
