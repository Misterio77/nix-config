{lib, config, ...}: {
  options = {
    home.exportedSessionPackages = lib.mkOption {
      type = lib.types.listOf lib.types.pathInStore;
      default = [];
    };
  };
}
