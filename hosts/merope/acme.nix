{
  environment.persistence."/data" = {
    directories = [ "/var/lib/acme" ];
  };
  security.acme = {
    email = "eu@misterio.me";
    acceptTerms = true;
    certs = {
      "bd.misterio.me" = {
        dnsProvider = "gandiv5";
        credentialsFile = "/data/etc/gandi/acme.key";
      };
    };
  };
}
