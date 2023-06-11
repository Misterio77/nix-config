{ config, inputs, pkgs, ... }: {
  imports = [
    inputs.disconic.nixosModules.default
  ];

  services.disconic = {
    enable = true;
    package = pkgs.inputs.disconic.default;
    user = "disconic";

    subsonicUrl = "https://music.m7.rs";
    subsonicUser = "misterio";
    discordGuild = "324685449937420288";

    subsonicPasswordFile = config.sops.secrets.disconic-ss-password.path;
    discordTokenFile = config.sops.secrets.disconic-discord-token.path;
  };

  sops.secrets = {
    disconic-ss-password = {
      owner = "disconic";
      group = "disconic";
      sopsFile = ../secrets.yaml;
    };
    disconic-discord-token = {
      owner = "disconic";
      group = "disconic";
      sopsFile = ../secrets.yaml;
    };
  };
}
