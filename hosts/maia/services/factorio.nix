{
  services.factorio = {
    enable = true;
    lan = true;
    nonBlockingSaving = true;
    game-name = "Setembrin";
    openFirewall = true;
    bind = "192.168.0.13";
  };

  environment.persistence = {
    "/persist".directories = [ "/var/lib/private/factorio" ];
  };
}
