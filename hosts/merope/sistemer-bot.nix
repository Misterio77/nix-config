{ inputs, ... }: {
  imports = [ inputs.sistemer-bot.nixosModule ];

  services.sistemer-bot = {
    enable = true;
    tokenFile = "/srv/sistemer_bot.key";
  };
}
