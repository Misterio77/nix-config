{ inputs, ... }: {
  imports = [ inputs.disconic.nixosModule ];

  services.disconic = {
    enable = true;
    subsonicUrl = "https://music.misterio.me";
    subsonicUser = "misterio";
    subsonicPasswordFile = "/srv/disconic/password";
    discordTokenFile = "/srv/disconic/token";
  };
}
