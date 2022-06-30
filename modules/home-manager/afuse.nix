{ lib, pkgs, config, ... }:

with lib;
let
  cfg = config.services.afuse;

  toValue = v: with builtins;
    if      ":" == v then "\\:"
    else if isString v ||
            isInt    v ||
            isFloat  v ||
            isPath   v then toString v
    else if isList   v then concatMapStringsSep ":" toValue v
    else abort "Unsupported afuse option: ${toString v}";

  toArgument = n: v: with builtins;
    if null       == v then ""
    else if false == v then ""
    else if true  == v then "-o ${n}"
    else if isAttrs  v then concatStringsSep " " (mapAttrsToList toArgument v)
    else "-o ${n}=\"${toValue v}\"";

  afuseArguments = {
    type = with types; anything;
    generate = toArgument;
  };
in
{
  options.services.afuse = {
    enable = mkEnableOption "afuse";

    package = mkOption {
      type = types.package;
      default = pkgs.afuse;
      defaultText = literalExpression "pkgs.afuse";
      description = "Package providing <command>afuse</command>";
    };

    mountpoint = mkOption {
      type = types.path;
      default = "/net";
      description = "Base mountpoint.";
    };

    debug = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to print more verbose messages.";
    };

    settings = mkOption {
      default = { };
      description = ''
        Options for afuse, passed as -o arguments. See <literal>afuse
        --help</literal> for supported options.
      '';

      type = types.submodule {
        freeformType = afuseArguments.type;

        # Important options
        options = {
          mount_template = mkOption {
            type = types.str;
            description = ''
              Template for command to execute on mount.

              When executed, %r and %m are expanded in templates to the root
              directory name for the new mount point, and the actual directory
              to mount onto respectively to mount onto.
            '';
            example = "sshfs %r:/ %m";
          };
          unmount_template = mkOption {
            type = types.str;
            description = ''
              Template for command to execute on unmount.

              Must be a lazy unmount operation.

              When executed, %r and %m are expanded in templates to the root
              directory name for the new mount point, and the actual directory
              to mount onto respectively to mount onto.
            '';
            example = "fusermount -u -z %m";
          };
          populate_root_command = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = ''
              Optional command for automatically populating mountpoints.

              This command must output one directory name per line.
            '';
          };
          filter_file = mkOption {
            type = types.nullOr types.path;
            default = null;
            description = ''
              Optional file containing glob entries for ignored mount points.
            '';
          };
        };
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services.afuse = {
      Unit = {
        Description = "afuse automatic FUSE mounter";
        After = [ "network.target" ];
      };
      Install.WantedBy = [ "default.target" ];
      Service = {
        ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${cfg.mountpoint}";
        ExecStart = replaceStrings ["%"] ["%%"] # Extra percent for escaping
        "${cfg.package}/bin/afuse ${optionalString cfg.debug "-d"} ${cfg.mountpoint} ${afuseArguments.generate null cfg.settings} -f";
      };
    };
  };
}
