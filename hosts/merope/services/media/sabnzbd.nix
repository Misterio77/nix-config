{config, lib, ...}: let
  downloadsDir = "/srv/downloads";
in {
  services.sabnzbd = {
    enable = true;
    configFile = config.sops.templates.sabnzbd-config.path;
  };
  sops.templates.sabnzbd-config = {
    content = /*ini*/ ''
      [misc]
      host = 127.0.0.1
      port = 6789
      local_ranges = 127.0.0.1/32
      api_key = ${config.sops.placeholder.sabnzbd-key}
      inet_exposure = 2
      download_dir = ${downloadsDir}/downloading
      complete_dir = ${downloadsDir}/complete
      log_dir = /var/lib/sabnzbd/logs
      admin_dir = /var/lib/sabnzbd/admin

      [servers]
      [[frugal]]
      enable = 1
      name = frugal
      host = sanews.frugalusenet.com
      port = 563
      username = misterio
      password = ${config.sops.placeholder.frugalusenet-key}
      connections = 8
      ssl = 1
      priority = 0
    '';
    owner = config.services.sabnzbd.user;
    group = config.services.sabnzbd.group;
    mode = "0600";
  };

  sops.secrets = {
    sabnzbd-key.sopsFile = ../../secrets.yaml;
    frugalusenet-key.sopsFile  = ../../secrets.yaml;
  };

  environment.persistence = {
    "/persist".directories = [
      {
        directory = downloadsDir;
        user = config.services.sabnzbd.user;
        group = config.services.sabnzbd.group;
        mode = "0770"; # So that others in the group (e.g. *arr) can move/hardlink completed torrents
      }
    ];
  };

  # Force disable file logging
  systemd.services.sabnzbd.serviceConfig.ExecStart = let
    cfg = config.services.sabnzbd;
  in lib.mkForce "${lib.getExe cfg.package} -d -f ${cfg.configFile} --disable-file-log";
}
