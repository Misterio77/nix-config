# System configuration for my Raspberry Pi 4
{ config, nixpkgs, pkgs, hardware, nur, impermanence, system, ... }:

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

    ./ddclient.nix
    ./projeto-bd.nix
    ./wireguard.nix
  ];

  environment.persistence."/data" = {
    directories = [
      "/var/log"
      "/var/lib/systemd"
      "/var/lib/postgresql"
      "/srv"
    ];
  };

  # Static IP address
  networking.networkmanager.extraConfig = ''
    [ipv4]
    address1=192.168.77.10/24
  '';

  services = {
    # Enable postgres
    postgresql.enable = true;

    # Enable sistemer telegram bot
    sistemer-bot = {
      enable = true;
      tokenFile = "/srv/sistemer_bot.key";
    };

    # Enable nginx and recommended settings
    nginx = {
      enable = true;
      recommendedTlsSettings = true;
      recommendedProxySettings = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
    };
  };
  # Open ports for nginx
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  # Passwordless sudo (for remote build)
  security.sudo.extraConfig = "%wheel ALL = (ALL) NOPASSWD: ALL";

  # Enable argonone fan daemon
  hardware.argonone.enable = true;
}
