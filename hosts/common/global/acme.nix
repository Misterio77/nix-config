{
  # Enable acme for usage with nginx vhosts
  security.acme = {
    defaults.email = "eu@misterio.me";
    acceptTerms = true;
  };

  environment.persistence = {
    "/persist".directories = [{
      directory = "/var/lib/acme";
      user = "acme";
      group = "acme";
      mode = "0700";
    }];
  };
}
