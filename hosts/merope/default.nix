# System configuration for my Raspberry Pi 4
{ config, pkgs, inputs, ... }:

{
  imports = [
    inputs.hardware.nixosModules.raspberry-pi-4
    inputs.impermanence.nixosModules.impermanence
    ./hardware-configuration.nix
    ./minecraft.nix
    ../common.nix
  ];

  networking.hostName = "default";
  nixpkgs = {
    config.allowUnfree = true;
    overlays = [ inputs.nur.overlay ];
  };

  # Opt-in persistence on /data
  environment.persistence."/data" = {
    directories = [
      "/var/log"
      "/var/lib/systemd"
      "/srv"
    ];
  };
  fileSystems."/data".neededForBoot = true;

  security = {
    # Passwordless sudo (for remote build)
    sudo.extraConfig = ''
      %wheel         ALL = (ALL) NOPASSWD: ALL
    '';
  };

  # My user info
  users.users.misterio = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.fish;
    # Grab hashed password from /data
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDci4wJghnRRSqQuX1z2xeaUR+p/muKzac0jw0mgpXE2T/3iVlMJJ3UXJ+tIbySP6ezt0GVmzejNOvUarPAm0tOcW6W0Ejys2Tj+HBRU19rcnUtf4vsKk8r5PW5MnwS8DqZonP5eEbhW2OrX5ZsVyDT+Bqrf39p3kOyWYLXT2wA7y928g8FcXOZjwjTaWGWtA+BxAvbJgXhU9cl/y45kF69rfmc3uOQmeXpKNyOlTk6ipSrOfJkcHgNFFeLnxhJ7rYxpoXnxbObGhaNqn7gc5mt+ek+fwFzZ8j6QSKFsPr0NzwTFG80IbyiyrnC/MeRNh7SQFPAESIEP8LK3PoNx2l1M+MjCQXsb4oIG2oYYMRa2yx8qZ3npUOzMYOkJFY1uI/UEE/j/PlQSzMHfpmWus4o2sijfr8OmVPGeoU/UnVPyINqHhyAd1d3Iji3y3LMVemHtp5wVcuswABC7IRVVKZYrMCXMiycY5n00ch6XTaXBwCY00y8B3Mzkd7Ofq98YHc= (none)"
    ];
  };
}
