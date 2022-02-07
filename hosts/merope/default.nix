# System configuration for my Raspberry Pi 4
{ config, pkgs, system, inputs, ... }:

let nur = import inputs.nur { nurpkgs = import inputs.nixpkgs { inherit system; }; };
in
{
  imports = [
    nur.repos.misterio.modules.argonone
    inputs.hardware.nixosModules.raspberry-pi-4
    inputs.sistemer-bot.nixosModule
    inputs.paste-misterio-me.nixosModule
    inputs.disconic.nixosModule

    ./hardware-configuration.nix
    ../common
    ../common/postgres.nix

    ./deluge.nix
    # ./ddclient.nix
    ./disconic.nix
    ./files-server.nix
    ./jitsi.nix
    ./minecraft.nix
    ./navidrome.nix
    ./nginx.nix
    ./paste-misterio-me.nix
    ./sistemer-bot.nix
    ./wireguard.nix
  ];

  # Static IP address
  networking.networkmanager.extraConfig = ''
    [connection-ethernet-eth0]
    match-device=interface-name:eth0
    ipv4.addresses=192.168.77.10/24
    ipv6.addresses=2804:14d:8084:a484:ffff:ffff:ffff:ffff/128
  '';

  # Open ports for nginx
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  # Passwordless sudo (for remote build)
  security.sudo.extraConfig = "%wheel ALL = (ALL) NOPASSWD: ALL";

  # Enable argonone fan daemon
  hardware.argonone.enable = true;
}
