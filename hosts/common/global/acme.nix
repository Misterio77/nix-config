{ persistence, lib, ... }:
{
  # Enable acme for usage with nginx vhosts
  security.acme = {
    defaults.email = "eu@misterio.me";
    acceptTerms = true;
  };

  environment.persistence = lib.mkIf persistence {
    "/persist" = {
      directories = [
        "/var/lib/acme"
      ];
    };
  };
}
