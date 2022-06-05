{ hostname, ... }: {
  boot.initrd ={
    luks.devices."${hostname}".device = "/dev/disk/by-label/${hostname}_crypt";
  };
}
