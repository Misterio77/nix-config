{config, ...}: {
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
      download_dir = /var/lib/sabnzbd/downloading
      complete_dir = /var/lib/sabnzbd/complete
      log_dir = /var/lib/sabnzbd/logs
      admin_dir = /var/lib/sabnzbd/admin
      backup_dir = /var/lib/sabnzbd/backup
      permissions = 770

      [categories]
      [[music]]
      name = music

      [servers]
      [[frugal]]
      enable = 1
      name = frugal
      host = sanews.frugalusenet.com
      ssl = 1
      port = 563
      username = misterio
      password = ${config.sops.placeholder.frugalusenet-key}
      connections = 150
      priority = 0
      [[frugal-secondary]]
      enable = 1
      name = frugal-secondary
      host = news.frugalusenet.com
      ssl = 1
      port = 563
      username = misterio
      password = ${config.sops.placeholder.frugalusenet-key}
      connections = 75
      priority = 1
      [[frugal-bonus]]
      enable = 1
      name = frugal-bonus
      host = bonus.frugalusenet.com
      ssl = 1
      port = 563
      username = misterio
      password = ${config.sops.placeholder.frugalusenet-key}
      connections = 50
      priority = 2
    '';
    owner = config.services.sabnzbd.user;
    group = config.services.sabnzbd.group;
    mode = "0600";
    restartUnits = ["sabnzbd.service"];
  };

  sops.secrets = {
    sabnzbd-key.sopsFile = ../../secrets.yaml;
    frugalusenet-key.sopsFile  = ../../secrets.yaml;
  };
}
