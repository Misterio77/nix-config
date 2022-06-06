{ persistence, inputs, lib, ... }: {
  imports = [
    inputs.impermanence.nixosModules.impermanence
  ];

  environment.persistence = lib.mkIf persistence {
    "/persist" = {
      directories = [
        "/var/log"
        "/var/lib/systemd"
        "/var/lib/acme"
        "/etc/NetworkManager/system-connections"
        "/srv/torrents"
        "/etc/ssh"
      ];
    };
  };

  # Allows accessing mountpoints when sudoing
  programs.fuse.userAllowOther = true;
}
