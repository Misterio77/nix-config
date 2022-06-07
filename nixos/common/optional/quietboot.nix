{
  boot = {
    plymouth.enable = true;
    loader.timeout = 0;
    kernelParams = [ "quiet" "udev.log_priority=3" "vt.global_cursor_default=0" ];
    consoleLogLevel = 0;
    initrd.verbose = false;
  };
}
