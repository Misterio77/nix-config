{pkgs, ...}: {
  services.printing = {
    enable = true;
    drivers = [
      pkgs.epson-escpr2
    ];
  };
}
