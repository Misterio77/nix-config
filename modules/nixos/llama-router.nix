{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.services.llama-router;
in {
  options.services.llama-router = {
    enable = lib.mkEnableOption "the local llama.cpp router API";

    package = lib.mkPackageOption pkgs "llama-cpp-vulkan" {};

    models = lib.mkOption {
      type = (pkgs.formats.ini {}).type;
      default = {};
      description = ''
        Model presets to serve, as an attrset mapping each model name to its
        llama-server settings (e.g. `hf`, `ctx-size`, `n-gpu-layers`).
      '';
    };

    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Address llama-server binds to.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 18080;
      description = "Port llama-server listens on.";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "llama";
      description = "User to run the router service as.";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "llama";
      description = "Group to run the router service as.";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users = lib.mkIf (cfg.user == "llama") {
      llama = {
        isSystemUser = true;
        group = cfg.group;
        home = "/var/lib/llama";
      };
    };
    users.groups = lib.mkIf (cfg.group == "llama") {
      llama = {};
    };

    systemd.services.llama-cpp-router = {
      description = "Local llama.cpp router API";
      after = ["network-online.target"];
      wants = ["network-online.target"];
      wantedBy = ["multi-user.target"];
      environment = {
        XDG_CACHE_HOME = "/var/lib/llama";
        XDG_DATA_HOME = "/var/lib/llama";
      };
      path = [cfg.package];
      script = lib.concatStringsSep " " [
        "llama-server"
        # No --models-dir: all models come from --models-preset below.
        "--models-preset ${(pkgs.formats.ini {}).generate "llama-cpp-models.ini" cfg.models}"
        "--models-max 1"
        "--host ${cfg.host}"
        "--port ${toString cfg.port}"
      ];
      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        StateDirectory = "llama";
        RuntimeDirectory = "llama";
        SupplementaryGroups = ["render" "video"];
        Restart = "on-failure";
        RestartSec = 2;
        # llama-server can dawdle on shutdown; SIGKILL it after 15s.
        TimeoutStopSec = 15;
      };
    };
  };
}
