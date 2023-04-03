# This file is imported on every host, for consistency.
# It works even if / is not ephemeral
{ lib, inputs, config, ... }: {
  imports = [
    inputs.impermanence.nixosModules.impermanence
  ];

  environment.persistence = {
    "/persist" = {
      directories = [
        "/var/lib/systemd"
        "/var/lib/nixos"
        "/var/log"
        "/srv"
      ];
    };
  };
  programs.fuse.userAllowOther = true;

  system.activationScripts.persistent-dirs.text =
  let
    mkHomePersist = user: lib.optionalString user.createHome ''
      mkdir -p /persist
      mkdir -p /persist/${user.home}
      chown -R ${user.name}:${user.group} /persist/${user.home}
      chmod ${user.homeMode} /persist/${user.home}
    '';
    createHomes = lib.concatLines (map mkHomePersist (lib.attrValues config.users.users));
  in ''
    mkdir -p /persist
    ${createHomes}
  '';
}
