{ config, ... }: {
  sops.secrets.wireless = {
    sopsFile = ../secrets.yaml;
    neededForUsers = true;
  };

  networking.wireless = {
    enable = true;
    environmentFile = config.sops.secrets.wireless.path;
    networks = {
      "Marcos_2.4Ghz" = {
        psk = "@PSK_MARCOS@";
      };
      "Misterio" = {
        psk = "@PSK_MISTERIO@";
      };
    };
  };
}
