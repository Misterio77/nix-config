{ pkgs, ... }:
{
  hardware.ckb-next = {
    enable = true;
  };

  systemd.services.ckb-next-resume = {
    description = "Restart ckb-next after hibernation";
    after = [ "suspend.target" ];
    wantedBy = [ "suspend.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.systemd}/bin/systemctl --no-block restart ckb-next.service";
    };
  };
}
