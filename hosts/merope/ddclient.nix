{
  services.ddclient = {
    enable = true;
    protocol = "gandi";
    zone = "misterio.me";
    domains = [ "home.misterio.me" ];
    username = "misterio";
    passwordFile = "/data/etc/gandi/ddclient.key";
  };
}
