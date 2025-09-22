{lib, pkgs, ...}: {
  users = {
    users.kiosk =  {
      home = "/home/kiosk";
      isNormalUser = true;
      group = "kiosk";
    };
    groups.kiosk = {};
  };

  services.greetd = {
    enable = true;
    settings = {
      initial_session = {
        command = "${lib.getExe pkgs.cage} ${lib.getExe pkgs.firefox} -kiosk https://media.m7.rs";
        user = "kiosk";
      };
    };
  };
}
