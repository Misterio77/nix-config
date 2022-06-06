{ lib, ... }: {
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_TIME = "pt_BR.UTF-8";
    };
  };
  time.timeZone = lib.mkDefault "America/Sao_Paulo";
}
