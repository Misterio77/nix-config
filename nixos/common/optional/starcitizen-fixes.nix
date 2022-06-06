{
  # https://github.com/starcitizen-lug/information-howtos/wiki

  # Blocks EAC CDN
  networking.extraHosts = ''
    127.0.0.1 modules-cdn.eac-prod.on.epicgames.com
  '';
  # Avoids crashes
  boot.kernel.sysctl = {
    "vm.max_map_count" = 16777216;
  };
}
