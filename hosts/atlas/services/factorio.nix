{ lib, ... }: {
  services.factorio = {
    enable = true;
    lan = true;
    game-name = "Setembrin";
    openFirewall = true;
    requireUserVerification = false;
    bind = "192.168.77.11";
  };

  environment.persistence = {
    "/persist".directories = [ "/var/lib/private/factorio" ];
  };
}
