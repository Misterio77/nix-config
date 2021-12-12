# System configuration for my Raspberry Pi 4
{ config, nixpkgs, pkgs, hardware, nur, impermanence, system, ... }:

let nur-no-pkgs = import nur { nurpkgs = import nixpkgs { inherit system; }; };
in
{
  imports = [
    hardware.nixosModules.raspberry-pi-4
    nur-no-pkgs.repos.misterio.modules.argonone

    ./hardware-configuration.nix
    ../common
    ../common/postgres.nix

    ./sistemer-bot.nix
    ./nginx.nix
    ./ddclient.nix
    ./projeto-bd.nix
    ./wireguard.nix
    ./minecraft.nix
  ];

  # Static IP address
  networking.networkmanager.extraConfig = ''
    [ipv4]
    address1=192.168.77.10/24
  '';

  # Open ports for nginx
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  # Passwordless sudo (for remote build)
  security.sudo.extraConfig = "%wheel ALL = (ALL) NOPASSWD: ALL";

  # Enable argonone fan daemon
  hardware.argonone.enable = true;
}
