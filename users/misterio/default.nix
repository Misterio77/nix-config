{ pkgs, ... }:

{
  # Require /data/home to be mounted at boot
  fileSystems."/data/home".neededForBoot = true;

  # User info
  users.users.misterio = {
    isNormalUser = true;
    extraGroups = [ "audio" "wheel" "docker" ];
    shell = pkgs.fish;
    # Grab hashed password from /data
    passwordFile = "/data/home/misterio/.password";
  };

  # Allow swaylock
  security.pam.services.swaylock = { };

  # Autologin at tty1
  systemd.services."autovt@tty1" = {
    description = "Autologin at the TTY1";
    after = [ "systemd-logind.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = [
        "" # override upstream default with an empty ExecStart
        "@${pkgs.utillinux}/sbin/agetty agetty --login-program ${pkgs.shadow}/bin/login --autologin misterio --noclear %I $TERM"
      ];
      Restart = "always";
      Type = "idle";
    };
  };

}
