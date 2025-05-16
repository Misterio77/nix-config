{pkgs, inputs, lib, ...}: {
  imports = [
    inputs.lanzaboote.nixosModules.lanzaboote
  ];

  boot.loader.systemd-boot.enable = lib.mkForce false;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };

  environment.systemPackages = [pkgs.sbctl];
  environment.persistence = {
    "/persist".directories = ["/var/lib/sbctl"];
  };
}
