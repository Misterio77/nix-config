{ persistence, inputs, lib, ... }:
{
  imports = [
    inputs.impermanence.nixosModules.impermanence
  ];

  environment.persistence = lib.mkIf persistence {
    "/persist" = {
      directories = [
        "/var/lib/systemd"
      ];
    };
  };

  # Allows accessing mountpoints when sudoing
  programs.fuse.userAllowOther = true;
}
