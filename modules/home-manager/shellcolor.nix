{ config, lib, pkgs, ... }:

let
  cfg = config.programs.shellcolor;
  package = pkgs.shellcolord;

  localCommand = pkgs.writeShellScriptBin "shellcolor-lc" ''
    ssh_pid=$(ps -o ppid= $PPID)
    shell_pid=$(ps -o ppid= $ssh_pid)

    pre() {
      ${package}/bin/shellcolor disable $shell_pid
    }

    post() {
      while kill -0 $ssh_pid &>/dev/null; do sleep 0.1; done
      ${package}/bin/shellcolor enable $shell_pid
      ${package}/bin/shellcolor apply $shell_pid
    }

    pre
    post & disown
  '';

  renderSetting = key: value: ''
    ${key}=${value}
  '';
  renderSettings = settings:
    lib.concatStrings (lib.mapAttrsToList renderSetting settings);

in {
  options.programs.shellcolor = {
    enable = lib.mkEnableOption "shellcolor";

    enableBashIntegration = lib.mkOption {
      default = true;
      type = lib.types.bool;
      description = ''
        Whether to enable Bash integration.
      '';
    };
    enableZshIntegration = lib.mkOption {
      default = true;
      type = lib.types.bool;
      description = ''
        Whether to enable Zsh integration.
      '';
    };
    enableFishIntegration = lib.mkOption {
      default = true;
      type = lib.types.bool;
      description = ''
        Whether to enable Fish integration.
      '';
    };

    enableSshIntegration = lib.mkOption {
      default = true;
      type = lib.types.bool;
      description = ''
        Whether to enable SSH integration.
      '';
    };

    settings = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      example = lib.literalExpression ''
        {
          base00 = "000000";
          base05 = "ffffff";
        }
      '';
      description = ''
        Options for shellcolord config file. Colors (without leading #)
        from base00 until base0F.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ package ];

    xdg.configFile."shellcolor.conf" = lib.mkIf (cfg.settings != { }) {
      text = renderSettings cfg.settings;
      onChange = ''
        timeout 1 ${package}/bin/shellcolor apply || true
      '';
    };

    programs.bash.initExtra = lib.mkIf cfg.enableBashIntegration
      (lib.mkBefore ''
        ${package}/bin/shellcolord $$ & disown
      '');

    programs.zsh.initExtra = lib.mkIf cfg.enableZshIntegration (lib.mkBefore ''
      ${package}/bin/shellcolord $$ & disown
    '');

    programs.fish.interactiveShellInit = lib.mkIf cfg.enableFishIntegration
      (lib.mkBefore ''
        ${package}/bin/shellcolord $fish_pid & disown
      '');

    programs.ssh.extraConfig = lib.mkIf cfg.enableSshIntegration
      (lib.mkBefore ''
        PermitLocalCommand=yes
        LocalCommand=${localCommand}/bin/shellcolor-lc
      '');
  };
}
