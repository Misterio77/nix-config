{config, ...}: {
  services.bazarr = {
    enable = true;
    listenPort = 8689;
  };

  environment.persistence = {
    "/persist".directories = [
      {
        directory = config.services.bazarr.dataDir;
        user = config.services.bazarr.user;
        group = config.services.bazarr.group;
        mode = "0700";
      }
    ];
  };
}
