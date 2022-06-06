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
        "/srv"
        "/dotfiles"
      ];
      files = [
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_ed25519_key.pub"
        "/etc/ssh/ssh_host_rsa_key"
        "/etc/ssh/ssh_host_rsa_key.pub"
      ];
    };
  };

  # Allows accessing mountpoints when sudoing
  programs.fuse.userAllowOther = true;
}
