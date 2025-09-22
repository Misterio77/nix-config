{lib, pkgs, ...}: {
  users.users.kiosk =  {
    home = "/home/kiosk";
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${lib.getExe pkgs.cage} ${lib.getExe pkgs.firefox} -kiosk https://media.m7.rs";
        user = "kiosk";
      };
    };
  };
}
