{config, lib, pkgs, ...}: let
  inherit (config.colorscheme) colors;
  setColor = color: "${lib.getExe pkgs.openrgb} --client -c ${lib.removePrefix "#"color} -m static";
in {
  systemd.user.services.rgb = {
    Unit = {
      Description = "Set RGB colors to match scheme. Requires openrgb.";
      X-SwitchMethod = "reload";
    };
    Service = {
      Type = "oneshot";
      ExecStart = setColor colors.inverse_primary;
      ExecReload = setColor colors.inverse_primary;
      ExecStop = setColor "#000000";
      Restart = "on-failure";
      RemainAfterExit = true;
    };
    Install.WantedBy = ["default.target"];
  };
}
