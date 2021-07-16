{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.ethminer;
  poolUrl = escapeShellArg "stratum1+ssl://${cfg.wallet}.${cfg.rig}@${cfg.pool}:${toString cfg.port}";
in

{

  ###### interface

  options = {

    services.ethminer = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable ethminer ether mining.";
      };

      wallet = mkOption {
        type = types.str;
        example = "0x0123456789abcdef0123456789abcdef01234567";
        description = "Ethereum wallet address.";
      };

      pool = mkOption {
        type = types.str;
        example = "eth-us-east1.nanopool.org";
        description = "Mining pool address.";
      };

      port = mkOption {
        type = types.port;
        default = 9999;
        description = "Stratum protocol tcp port.";
      };

      rig = mkOption {
        type = types.str;
        default = "mining-rig-name";
        description = "Mining rig name.";
      };

    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    systemd.user.services.ethminer = {
      Unit = {
        Description = "ethminer ethereum mining service";
        After = [ "network.target" ];
      };
      Service = {
        ExecStartPre = "${pkgs.ethminer-free}/bin/.ethminer-wrapped --list-devices";
        ExecStart = "${pkgs.ethminer-free}/bin/.ethminer-wrapped --opencl --report-hashrate --pool ${poolUrl}";
        Restart = "always";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
