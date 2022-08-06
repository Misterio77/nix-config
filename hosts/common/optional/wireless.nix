{ config, persistence, lib, ... }: {
  # Wireless secrets stored through sops
  sops.secrets.wireless = {
    sopsFile = ../secrets.yaml;
    neededForUsers = true;
  };

  networking.wireless = {
    enable = true;
    # Declarative
    environmentFile = config.sops.secrets.wireless.path;
    networks = {
      /*
        "Marcos_2.4Ghz" = {
        psk = "@PSK_MARCOS@";
        };
      */
      "Misterio" = {
        psk = "@PSK_MISTERIO@";
      };
    };

    # Imperative
    allowAuxiliaryImperativeNetworks = true;
    userControlled = {
      enable = true;
      group = "network";
    };
  };

  # Ensure group exists
  users.groups.network = { };

  # Persist imperative config
  environment.persistence = lib.mkIf persistence {
    "/persist".files = [
      "/etc/wpa_supplicant.conf"
    ];
  };
}
