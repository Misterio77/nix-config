{ lib, pkgs, config, ... }:

with lib;
let
  inherit (lib) mkEnableOption;
  cfg = config.services.afuse;

  toValue = v: with builtins;
    if      ":" == v then "\\:"
    else if isString v ||
            isInt    v ||
            isFloat  v ||
            isPath   v then toString v
    else if isList   v then concatMapStringsSep ":" toValue v
    else abort "Unsupported afuse option: ${toString v}";

  toArgument = f: n: v: with builtins;
    if null       == v then ""
    else if false == v then ""
    else if true  == v then "${f} ${v}"
    else if isAttrs  v then concatStringsSep " " (mapAttrsToList toArgument v)
    else "${f} ${n}=${toValue v}";

  afuseArguments = {
    type = with types; let
      valueType = attrsOf (oneOf [
        bool
        str int float path
        (listOf oneOf [ str int float path])
      ]) // {
        description = ''
          An attrset where each values must be:

          String, path, numbers, list (values colon separated), or boolean
        '';
      };
    in valueType;

    generate = flag: value: concatStringsSep " " (toArgument flag null value);
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

    settings = mkOption {
      type = types.submodule {
        freeformType = afuseArguments.type;
        default = { };
        description = ''
          Options for afuse, in key values pairs (passed as -o arguments). See
          <literal>afuse --help</literal> for supported options.
        '';

        # Important options
        options = {
          subdir = mkOption {
            type = types.path;
            description = ''
              Root that should have all mountpoints.
            '';
            example = "/home/you/Shares";
          };
          mount_template = mkOption {
            type = types.str;
            description = ''
              Template for command to execute on mount.

              %r and %m are expanded, respectively, into the directory for the mount
              point, and full directory to mount onto.
            '';
            example = "sshfs $r:/ %m";
          };
          unmount_template = mkOption {
            type = types.str;
            description = ''
              Template for command to execute on unmount.

              Must be a lazy unmount operation.

              %r and %m are expanded, respectively, into the directory for the mount
              point, and full directory to mount onto.
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
      Unit.Description = "afuse automatic FUSE mounter";
      Install.WantedBy = [ "default.target" ];
      Service.ExecStart = "${cfg.package}/bin/afuse ${afuseArguments "-o" cfg.settings} -f";
    };
  };
}
