{ inputs, config, ... }:
{
  imports = [
    inputs.firefly-bot.nixosModules.default
  ];

  services.firefly-bot = {
    enable = true;
    environmentFile = config.sops.secrets.firefly-bot-env.path;
  };

  sops.secrets.firefly-bot-env = {
    owner = "firefly-bot";
    group = "firefly-bot";
    sopsFile = ../secrets.yaml;
  };
}
