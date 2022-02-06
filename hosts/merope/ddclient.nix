{
  services.ddclient = {
    enable = true;
    protocol = "gandi";
    zone = "misterio.me";
    domains = [ "home.misterio.me" ];
    username = "misterio";
    passwordFile = "/persist/etc/gandi/ddclient.key";
  };
}
