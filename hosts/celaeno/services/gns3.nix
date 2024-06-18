{config, pkgs, lib, ...}: {
  services.gns3-server = {
    enable = true;
    settings.Server = {
      host = "0.0.0.0";
      port = 3080;
      ubridge_path = lib.mkForce "/run/wrappers/bin/ubridge";
    };
    dynamips.enable = true;
    ubridge.enable = true;
    vpcs.enable = true;
  };

  users.groups.gns3 = { };
  users.users.gns3 = {
    group = "gns3";
    isSystemUser = true;
    shell = pkgs.bashInteractive;
  };
  systemd.services.gns3-server.serviceConfig = {
    User = "gns3";
    DynamicUser = lib.mkForce false;
    NoNewPrivileges = lib.mkForce false;
    RestrictSUIDSGID = lib.mkForce false;
    PrivateUsers = lib.mkForce false;
    DeviceAllow = [
      "/dev/net/tun rw"
      "/dev/net/tap rw"
    ] ++ lib.optionals config.virtualisation.libvirtd.enable [
      "/dev/kvm"
    ];
    UMask = lib.mkForce "0022";
  };


  services.nginx.virtualHosts."gns3.m7.rs" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://localhost:3080";
      proxyWebsockets = true;
      basicAuthFile = config.sops.secrets.gns3-password.path;
    };
  };

  sops.secrets.gns3-password = {
    owner = "nginx";
    group = "nginx";
    sopsFile = ../secrets.yaml;
  };
}
