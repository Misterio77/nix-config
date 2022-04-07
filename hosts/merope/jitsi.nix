{ ... }:
{
  services = {
    jitsi-meet = {
      enable = true;
      hostName = "jitsi.misterio.me";
      interfaceConfig = {
        APP_NAME = "Meet do Gabiru";
        SHOW_JITSI_WATERMARK = false;
        DISPLAY_WELCOME_FOOTER = false;
      };
      nginx.enable = true;
      # Can't enable this until chromedriver is packaged for aarch64
      # jibri.enable = true;
    };
  };

  networking.firewall = {
    allowedUDPPorts = [ 10000 ];
  };
}
