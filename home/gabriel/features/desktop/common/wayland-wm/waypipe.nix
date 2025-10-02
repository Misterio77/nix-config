{pkgs, lib, config, ...}: {
  home.packages = [pkgs.waypipe];
  systemd.user.services.waypipe-client = {
    Unit.Description = "Runs waypipe client on startup to support SSH forwarding";
    Service = {
      ExecStartPre = "${lib.getExe' pkgs.coreutils "mkdir"} %h/.waypipe -p";
      ExecStart = "${lib.getExe (config.lib.nixGL.wrap pkgs.waypipe)} --socket %h/.waypipe/client.sock client";
      ExecStopPost = "${lib.getExe' pkgs.coreutils "rm"} -f %h/.waypipe/client.sock";
    };
    Install.WantedBy = ["graphical-session.target"];
  };
}
