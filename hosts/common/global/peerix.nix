{ config, inputs, ... }:
{
  imports = [ inputs.peerix.nixosModules.peerix ];

  services.peerix = {
    enable = true;
    openFirewall = true;
    privateKeyFile = config.sops.secrets.peerix-key.path;
    publicKey = "peerix:kkLEVAiNwU0AU8bCba5jWGSs5wv8djfvBt5ByJXCKiY=";
  };
  sops.secrets.peerix-key.sopsFile = ../secrets.yaml;
}
