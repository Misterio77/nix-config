{ config, pkgs, ... }:
let
  homeDir = config.home.homeDirectory;

  listTailscaleDevices = "${tailscale} status --active --self=false | ${tr} -s ' ' | ${cut} -d ' ' -f2";

  tr = "${pkgs.coreutils}/bin/tr";
  cut = "${pkgs.coreutils}/bin/cut";
  tailscale = "${pkgs.tailscale}/bin/tailscale";
  sshfs = "${pkgs.sshfs}/bin/sshfs";
  fusermount = "${pkgs.fuse}/bin/fusermount";
in
{
  services.afuse = {
    enable = true;
    mountpoint = "${homeDir}/Network";
    settings = {
      mount_template = "${sshfs} %r:${homeDir} %m";
      unmount_template = "${fusermount} -u -z %m";
      populate_root_command = listTailscaleDevices;

      timeout = 300;
      auto_unmount = true;
      allow_root = true;
      auto_cache = true;
      remember = 10;
      intr = true;
    };
  };
}
