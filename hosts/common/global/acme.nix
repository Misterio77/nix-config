{
  # Enable acme for usage with nginx vhosts
  security.acme = {
    defaults.email = "eu@misterio.me";
    acceptTerms = true;
  };

  environment.persistence = {
    "/persist" = {
      directories = ["/var/lib/acme"];
    };
  };
}
