{ config, lib, pkgs, ... }:

let
  cfg = config.services.photoprism;
  defaultUser = "photoprism";
  defaultGroup = defaultUser;
in
{
  options.services.photoprism = with lib; {
    enable = mkEnableOption "photoprism";

    user = mkOption {
      type = types.str;
      default = defaultUser;
      example = "yourUser";
      description = ''
        The user to run Photoprism as.
        By default, a user named <literal>${defaultUser}</literal> will be created.
      '';
    };

    group = mkOption {
      type = types.str;
      default = defaultGroup;
      example = "yourGroup";
      description = ''
        The group to run Photoprism under.
        By default, a group named <literal>${defaultGroup}</literal> will be created.
      '';
    };

    host = mkOption {
      type = types.str;
      default = "127.0.0.1";
      example = "0.0.0.0";
      description = "The address to serve the web interface at.";
    };

    port = mkOption {
      type = types.int;
      default = 2342;
      description = "The port to serve the web interface at.";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Open the web interface port in the firewall for photoprism.";
    };

    databaseDriver = mkOption {
      type = types.enum [ "sqlite" "mysql" ];
      default = "sqlite";
      description = ''
        Database driver, select mysql to use an embedded database.

        Photoprism recommends a maria database (using the
        <literal>"mysql"</literal> driver) to improve performance.
      '';
    };

    databaseDsn = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = ''
        photoprism@unix(/run/mysqld/mysqld.sock)/photoprism?charset=utf8mb4,utf8&parseTime=true
      '';
      description = ''
        Photoprism database source name. Valid only when
        <link linkend="opt-services.photoprism.databaseDriver">databaseDriver</link>
        is set to <literal>"mysql"</literal>.
      '';
    };

    initialPassword = mkOption {
      type = types.str;
      default = "insecure";
      description = ''
        Initial admin password.

        This should be changed in the web UI after the first startup.
      '';
    };

    detectNsfw = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Flag photos as private that MAY be offensive.
      '';
    };

    allowNsfw = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Allow uploads that MAY be offensive.
      '';
    };

    experimental = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable experimental features.
      '';
    };

    originalsLimit = mkOption {
      type = types.int;
      default = 5000;
      description = ''
        File size limit for originals in MB (increase for high-res video).
      '';
    };

    public = mkOption {
      type = types.bool;
      default = false;
      description = ''
        No authentication required (disables password protection).
      '';
    };

    readonly = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Do not modify originals directory (reduced functionality).
      '';
    };

    originalsDir = mkOption {
      type = types.str;
      example = "/mnt/nas/photos";
      description = "Path to your photos.";
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/photoprism";
      description = "Data directory for photoprism.";
    };

    siteTitle = mkOption {
      type = types.str;
      default = "PhotoPrism";
      description = "Web UI title.";
    };

    siteCaption = mkOption {
      type = types.str;
      default = "Browse Your Life";
      description = "Web UI caption.";
    };

    extraEnv = mkOption {
      type = types.attrsOf types.str;
      default = { };
      example = { PHOTOPRISM_DEBUG = "true"; };
      description = ''
        Additional environment variables for the photoprism service.

        See <link xlink:href="https://dl.photoprism.app/docker/docker-compose.yml"/>
        and <link xlink:href="https://github.com/photoprism/photoprism/blob/develop/internal/config/flags.go">
        for the supported environment variables.
      '';
    };

    package = mkOption {
      type = types.package;
      default = pkgs.photoprism;
      description = "Photoprism package to use.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.databaseDriver == "sqlite" -> (cfg.databaseDsn == null);
        message = "SQLite is an internal database, databaseDsn must be null";
      }
      {
        assertion = cfg.databaseDriver == "mysql" -> (cfg.databaseDsn != null);
        message = "databaseDsn must be provided when using mysql databases";
      }
    ];

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
    };

    users = {
      users.${cfg.user} = {
        inherit (cfg) group;
        home = cfg.dataDir;
        createHome = true;
        isSystemUser = true;
      };
      groups.${cfg.group} = { };
    };

    systemd.services.photoprism = {
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = ''
          ${cfg.package}/bin/photoprism --assets-path ${cfg.package}/assets start
        '';
        User = cfg.user;
        Group = cfg.group;

        # hardening
        DevicePolicy = "closed";
        CapabilityBoundingSet = "";
        RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_UNIX" "AF_NETLINK" ];
        DeviceAllow = "";
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        BindPaths = [
          cfg.dataDir
          cfg.originalsDir
        ] ++ lib.optionals (cfg.databaseDriver == "mysql") [
          "-/run/mysqld"
          "-/var/run/mysqld"
        ];
        LockPersonality = true;
        RemoveIPC = true;
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = [
          "~@clock"
          "~@debug"
          "~@module"
          "~@mount"
          "~@raw-io"
          "~@reboot"
          "~@swap"
          "~@privileged"
          "~@resources"
          "~@cpu-emulation"
          "~@obsolete"
        ];
        SystemCallErrorNumber = "EPERM";
        ProtectHostname = true;
      };

      environment = lib.recursiveUpdate {
        PHOTOPRISM_ADMIN_PASSWORD = cfg.initialPassword;
        PHOTOPRISM_HTTP_HOST = cfg.host;
        PHOTOPRISM_HTTP_PORT = toString cfg.port;
        PHOTOPRISM_SITE_URL = "http://${cfg.host}:${toString cfg.port}/";

        PHOTOPRISM_DATABASE_DRIVER = cfg.databaseDriver;
        PHOTOPRISM_DATABASE_DSN =
          if cfg.databaseDriver == "sqlite" then "${cfg.dataDir}/photoprism.sqlite"
          else cfg.databaseDsn;

        PHOTOPRISM_DETECT_NSFW = toString cfg.detectNsfw;
        PHOTOPRISM_UPLOAD_NSFW = toString cfg.allowNsfw;
        PHOTOPRISM_EXPERIMENTAL = toString cfg.experimental;
        PHOTOPRISM_ORIGINALS_LIMIT = toString cfg.originalsLimit;
        PHOTOPRISM_PUBLIC = toString cfg.public;
        PHOTOPRISM_READONLY = toString cfg.readonly;

        PHOTOPRISM_SITE_TITLE = cfg.siteTitle;
        PHOTOPRISM_SITE_CAPTION = cfg.siteCaption;

        PHOTOPRISM_SIDECAR_PATH = "${cfg.dataDir}/sidecar";
        PHOTOPRISM_STORAGE_PATH = "${cfg.dataDir}/storage";
        PHOTOPRISM_ASSETS_PATH = "${cfg.package}/assets";
        PHOTOPRISM_ORIGINALS_PATH = cfg.originalsDir;
        PHOTOPRISM_IMPORT_PATH = "${cfg.dataDir}/import";
      } cfg.extraEnv;
    };
  };
}
