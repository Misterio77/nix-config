{ config, lib, pkgs, ... }:

let
  cfg = config.programs.shellcolor;
  package = pkgs.shellcolord;

  renderSetting = key: value: ''
    ${key}=${value}
  '';
  renderSettings = settings:
    lib.concatStrings (lib.mapAttrsToList renderSetting settings);

in
{
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

    enableBashSshFunction = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = ''
        Whether to enable SSH integration by replacing ssh with a bash function.
      '';
    };
    enableFishSshFunction = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = ''
        Whether to enable SSH integration by replacing ssh with a fish function.
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
        ${lib.optionalString cfg.enableBashSshFunction ''
        ssh() {
          ${package}/bin/shellcolor disable $$
          command ssh "$@"
          ${package}/bin/shellcolor enable $$
          ${package}/bin/shellcolor apply $$
        }
        ''}
      '');

    programs.zsh.initExtra = lib.mkIf cfg.enableZshIntegration (lib.mkBefore ''
      ${package}/bin/shellcolord $$ & disown
    '');

    programs.fish.interactiveShellInit = lib.mkIf cfg.enableFishIntegration
      (lib.mkBefore ''
        ${package}/bin/shellcolord $fish_pid & disown
      '');

    programs.fish.functions.ssh = lib.mkIf cfg.enableFishSshFunction ''
      ${package}/bin/shellcolor disable $fish_pid
      command ssh $argv
      ${package}/bin/shellcolor enable $fish_pid
      ${package}/bin/shellcolor apply $fish_pid
    '';
  };
}
