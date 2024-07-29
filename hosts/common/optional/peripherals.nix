{
  services.hardware = {
    openrgb.enable = true;
  };
  hardware = {
    keyboard.qmk.enable = true;
    openrazer = {
      enable = true;
      batteryNotifier.enable = true;
      devicesOffOnScreensaver = true;
      keyStatistics = true;
    };
    opentabletdriver.enable = true;
  };
}
