{config, pkgs, lib, ...}: {
  systemd.user.services.clip-notify = {
    Unit = {
      Description = "Clipboard copy notifications";
      PartOf = [config.wayland.systemd.target];
      After = [config.wayland.systemd.target];
    };
    Service = {
      Type = "simple";
      ExecStart = "${lib.getExe' pkgs.wl-clipboard "wl-paste"} --watch ${lib.getExe pkgs.clip-notify}";
      Restart = "on-failure";
    };
    Install.WantedBy = [config.wayland.systemd.target];
  };
}
