{config, lib, ...}: {
  users.users.greeter = {
    extraGroups = ["seat"];
  };
  services = {
    seatd.enable = true;
    greetd.enable = true;
    displayManager = {
      enable = true;
      # Export user sessions to system
      sessionPackages = lib.flatten (lib.mapAttrsToList (_: v: v.home.exportedSessionPackages) config.home-manager.users);
    };
  };
}
