{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) types mkEnableOption mkPackageOption mkOption mkIf optionalAttrs mapAttrs' nameValuePair;
  cfg = config.services.opencode;
  format = pkgs.formats.json {};
  mapAttrNames = f: mapAttrs' (n: v: nameValuePair (f n) v);

  dirType = types.mkOptionType {
    name = "opencode-directory";
    description = "Path to a directory.";
    check = types.path.check;
    inherit (types.path) merge;
  };

  wrapDir = filename: path:
    pkgs.runCommand "dir" {preferLocalBuild = true;} ''
      if [ -d "${path}" ]; then
        ln -s "${path}" "$out"
      else
        mkdir -p "$out"
        ln -s "${path}" "$out/${filename}"
      fi
    '';

  mkConfigEntry = name: path:
    pkgs.runCommand "entry" {preferLocalBuild = true;} ''
      if [ -d ${lib.escapeShellArg path} ]; then
        cd ${lib.escapeShellArg path}
        find -L . -type f -o -type l | while IFS= read -r f; do
          f=''${f#./}
          mkdir -p "$out/${lib.escapeShellArg name}/$(dirname "$f")"
          ln -s "$(realpath "${path}/$f")" "$out/${lib.escapeShellArg name}/$f"
        done
      else
        mkdir -p "$(dirname "$out/${lib.escapeShellArg name}")"
        ln -s ${lib.escapeShellArg path} "$out/${lib.escapeShellArg name}"
      fi
    '';
in {
  options.services.opencode = {
    enable = mkEnableOption "OpenCode AI coding agent server";

    package = mkPackageOption pkgs "opencode" {};

    port = mkOption {
      type = types.port;
      default = 4096;
      description = "Port for the opencode server to listen on.";
    };

    hostname = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "Hostname for the opencode server to bind to.";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Open the server port in the firewall.";
    };

    environmentFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      example = "/run/secrets/opencode-server";
      description = ''
        Path to an EnvironmentFile with OPENCODE_SERVER_PASSWORD and API keys.
      '';
    };

    settings = mkOption {
      inherit (format) type;
      default = {};
      example = {
        model = "deepseek/deepseek-v4-flash";
        autoupdate = false;
      };
      description = ''
        Managed configuration.
        See https://opencode.ai/docs/config/ for all options.
      '';
    };

    extraArgs = mkOption {
      type = types.listOf types.str;
      default = [];
      example = ["--cors" "http://localhost:5173" "--log-level" "DEBUG"];
      description = "Extra arguments passed to opencode serve.";
    };

    context = mkOption {
      type = types.nullOr (types.coercedTo types.lines (pkgs.writeText "AGENTS.md") types.path);
      default = null;
      description = "Global context for OpenCode, written to AGENTS.md.";
    };

    agents = mkOption {
      type = types.attrsOf (types.coercedTo types.lines (pkgs.writeText "agent.md") types.path);
      default = {};
      example = {
        code-reviewer = "# Code Reviewer\nReview code.";
      };
      description = "Custom agents.";
    };

    skills = mkOption {
      type = types.attrsOf (
        types.coercedTo (
          types.coercedTo
          types.lines
          (pkgs.writeText "SKILL.md")
          types.path
        )
        (wrapDir "SKILL.md")
        dirType
      );
      default = {};
      example = {
        data-analysis = ./skills/data-analysis;
      };
      description = "Custom skills. Text, file, or directory.";
    };

    commands = mkOption {
      type = types.attrsOf (types.coercedTo types.lines (pkgs.writeText "command.md") types.path);
      default = {};
      description = "Custom slash commands.";
    };

    tools = mkOption {
      type = types.attrsOf (types.coercedTo types.lines (pkgs.writeText "tool.ts") types.path);
      default = {};
      description = "Custom tools.";
    };

    extraFiles = mkOption {
      type = types.attrsOf types.path;
      default = {};
      example = {
        "agents/secrets.md" = "secret agent";
      };
      description = "Additional files under /etc/opencode/.";
    };
  };

  config = mkIf cfg.enable {
    services.opencode.extraFiles =
      {"opencode.json" = format.generate "opencode.json" cfg.settings;}
      // (lib.optionalAttrs (cfg.context != null) {"AGENTS.md" = cfg.context;})
      // (mapAttrNames (n: "agents/${n}.md") cfg.agents)
      // (mapAttrNames (n: "commands/${n}.md") cfg.commands)
      // (mapAttrNames (n: "tools/${n}.ts") cfg.tools)
      // (mapAttrNames (n: "skills/${n}") cfg.skills);

    systemd.services.opencode = let
      configDir = pkgs.symlinkJoin {
        name = "opencode-config";
        paths = lib.mapAttrsToList mkConfigEntry cfg.extraFiles;
      };
    in {
      description = "OpenCode AI Coding Agent Server";
      after = ["network.target"];
      wantedBy = ["multi-user.target"];
      path = [
        # Give the daemon access to nix, bash, and python3 for basic stuff.
        config.nix.package
        pkgs.bash
        pkgs.python3
      ];
      environment = {
        # Ephemeral (does not survive restart)
        OPENCODE_CONFIG_DIR = "/run/opencode/config";
        XDG_CACHE_HOME = "/run/opencode/cache";
        HOME = "/run/opencode"; # Must be ephemeral, or else opencode can change its own config
        # Persistent (survives restarts)
        XDG_DATA_HOME = "/var/lib/opencode/data";
      };
      preStart = ''
        mkdir -p /run/opencode/config
        ${lib.getExe pkgs.lndir} -silent ${configDir} /run/opencode/config
      '';

      serviceConfig =
        {
          Type = "simple";
          User = "opencode";
          ExecStart = "${lib.getExe cfg.package} serve --hostname ${cfg.hostname} --port ${toString cfg.port} ${lib.escapeShellArgs cfg.extraArgs}";
          Restart = "on-failure";
          RestartSec = "5";
          RuntimeDirectory = "opencode";
          StateDirectory = "opencode";
          # Hardening
          TemporaryFileSystem = "/run"; # Hide everything in /run except the whitelist below
          BindPaths = ["/run/opencode" "/run/secrets"];
          CapabilityBoundingSet = "";
          DevicePolicy = "closed";
          LockPersonality = true;
          NoNewPrivileges = true;
          PrivateDevices = true;
          PrivateTmp = true;
          PrivateUsers = true;
          ProtectClock = true;
          ProtectControlGroups = true;
          ProtectHome = "yes";
          ProtectHostname = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectProc = "invisible";
          ProtectSystem = "strict";
          RestrictAddressFamilies = ["AF_INET" "AF_INET6" "AF_UNIX"];
          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          SystemCallArchitectures = "native";
          SystemCallFilter = "@system-service";
        }
        // (optionalAttrs (cfg.environmentFile != null) {
          EnvironmentFile = cfg.environmentFile;
        });
    };

    users.users.opencode = {
      isSystemUser = true;
      group = "opencode";
    };
    users.groups.opencode = {};

    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [cfg.port];
  };
}
