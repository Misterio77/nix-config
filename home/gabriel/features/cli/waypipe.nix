{pkgs, lib, ...}: {
  home.packages = [pkgs.waypipe];
  systemd.user.services = {
    waypipe-client = {
      Unit.Description = "Runs waypipe on startup to support SSH forwarding";
      Service = {
        ExecStartPre = "${lib.getExe' pkgs.coreutils "mkdir"} %h/.waypipe -p";
        ExecStart = "${lib.getExe pkgs.waypipe} --socket %h/.waypipe/client.sock client";
      };
      Install.WantedBy = ["default.target"];
    };
    waypipe-server = {
      Unit.Description = "Runs waypipe on startup to support SSH forwarding";
      Service = {
        Type = "simple";
        ExecStartPre = "${lib.getExe' pkgs.coreutils "mkdir"} %h/.waypipe -p";
        ExecStart = "${lib.getExe pkgs.waypipe} --socket %h/.waypipe/server.sock --no-gpu --display %h/.waypipe/display server -- ${lib.getExe' pkgs.coreutils "sleep"} inf";
      };
      Install.WantedBy = ["default.target"];
    };
  };
}
