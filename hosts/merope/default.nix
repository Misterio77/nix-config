# System configuration for my Raspberry Pi 4
{ config, pkgs, hardware, impermanence, ... }:

{
  imports = [
    hardware.nixosModules.raspberry-pi-4
    impermanence.nixosModules.impermanence
    ./hardware-configuration.nix
    ../common.nix
  ];

  networking.hostName = "merope";

  # Opt-in persistence on /data
  fileSystems."/data".neededForBoot = true;
  environment.persistence."/data" = {
    directories = [
      "/var/log"
      "/var/lib/systemd"
      "/srv"
    ];
  };

  # Persist host ssh keys
  services.openssh.hostKeys = [
    {
      path = "/data/etc/ssh/ssh_host_ed25519_key";
      type = "ed25519";
    }
    {
      path = "/data/etc/ssh/ssh_host_rsa_key";
      type = "rsa";
      bits = "4096";
    }
  ];

  security = {
    # Passwordless sudo (for remote build)
    sudo.extraConfig = ''
      %wheel         ALL = (ALL) NOPASSWD: ALL
    '';
  };

  # Enable i2c gpio
  hardware.i2c.enable = true;
  hardware.raspberry-pi."4".i2c-bcm2708.enable = true;
  boot.kernelModules = [ "i2c-dev" "i2c-piix4" "i2c_bcm2835" ];

  # My user info
  users.users.misterio = {
    isNormalUser = true;
    extraGroups = [ "wheel" "i2c" ];
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDci4wJghnRRSqQuX1z2xeaUR+p/muKzac0jw0mgpXE2T/3iVlMJJ3UXJ+tIbySP6ezt0GVmzejNOvUarPAm0tOcW6W0Ejys2Tj+HBRU19rcnUtf4vsKk8r5PW5MnwS8DqZonP5eEbhW2OrX5ZsVyDT+Bqrf39p3kOyWYLXT2wA7y928g8FcXOZjwjTaWGWtA+BxAvbJgXhU9cl/y45kF69rfmc3uOQmeXpKNyOlTk6ipSrOfJkcHgNFFeLnxhJ7rYxpoXnxbObGhaNqn7gc5mt+ek+fwFzZ8j6QSKFsPr0NzwTFG80IbyiyrnC/MeRNh7SQFPAESIEP8LK3PoNx2l1M+MjCQXsb4oIG2oYYMRa2yx8qZ3npUOzMYOkJFY1uI/UEE/j/PlQSzMHfpmWus4o2sijfr8OmVPGeoU/UnVPyINqHhyAd1d3Iji3y3LMVemHtp5wVcuswABC7IRVVKZYrMCXMiycY5n00ch6XTaXBwCY00y8B3Mzkd7Ofq98YHc= (none)"
    ];
  };
}
