# System configuration for my Raspberry Pi 4
{ config, nixpkgs, system, pkgs, hardware, impermanence, nur, ... }:

let
  nur-no-pkgs = import nur {
    nurpkgs = import nixpkgs { inherit system; };
  };
in
{
  imports = [
    hardware.nixosModules.raspberry-pi-4
    impermanence.nixosModules.impermanence
    nur-no-pkgs.repos.misterio.modules.argonone
    ../common.nix
    ./hardware-configuration.nix

    ./acme.nix
    ./ddclient.nix
    ./projeto-bd.nix
    ./wireguard.nix
  ];

  networking.hostName = "merope";

  networking.networkmanager.extraConfig = ''
    [ipv4]
    address1=192.168.77.10/24
  '';

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

  # Enable wireguard ip forwarding
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  security = {
    # Passwordless sudo (for remote build)
    sudo.extraConfig = ''
      %wheel         ALL = (ALL) NOPASSWD: ALL
    '';
  };

  # Enable argonone fan daemon
  hardware.argonone.enable = true;

  # Enable sistemer telegram bot
  services.sistemer-bot = {
    enable = true;
    tokenFile = "/srv/sistemer_bot.key";
  };

  # My user info
  users.users.misterio = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "i2c" ];
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDci4wJghnRRSqQuX1z2xeaUR+p/muKzac0jw0mgpXE2T/3iVlMJJ3UXJ+tIbySP6ezt0GVmzejNOvUarPAm0tOcW6W0Ejys2Tj+HBRU19rcnUtf4vsKk8r5PW5MnwS8DqZonP5eEbhW2OrX5ZsVyDT+Bqrf39p3kOyWYLXT2wA7y928g8FcXOZjwjTaWGWtA+BxAvbJgXhU9cl/y45kF69rfmc3uOQmeXpKNyOlTk6ipSrOfJkcHgNFFeLnxhJ7rYxpoXnxbObGhaNqn7gc5mt+ek+fwFzZ8j6QSKFsPr0NzwTFG80IbyiyrnC/MeRNh7SQFPAESIEP8LK3PoNx2l1M+MjCQXsb4oIG2oYYMRa2yx8qZ3npUOzMYOkJFY1uI/UEE/j/PlQSzMHfpmWus4o2sijfr8OmVPGeoU/UnVPyINqHhyAd1d3Iji3y3LMVemHtp5wVcuswABC7IRVVKZYrMCXMiycY5n00ch6XTaXBwCY00y8B3Mzkd7Ofq98YHc= (none)"
    ];
  };
}
