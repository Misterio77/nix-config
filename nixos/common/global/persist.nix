{ persistence, inputs, lib, ... }: {
  imports = [
    inputs.impermanence.nixosModules.impermanence
  ];

  environment.persistence = lib.mkIf persistence {
    "/persist" = {
      directories = [
        "/etc/ssh"
        "/var/log"
        "/var/lib/systemd"
        "/var/lib/acme"
        "/etc/NetworkManager/system-connections"
      ];
    };
  };

  fileSystems."/etc/ssh" = {
    # Fix secrets being activated before etc ssh is mounted
    neededForBoot = true;
    # Make sure persist is mounted
    # https://github.com/nix-community/impermanence/issues/22
    depends = [ "/persist" ];
  };


  # Allows accessing mountpoints when sudoing
  programs.fuse.userAllowOther = true;
}
