{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.system.hydraAutoUpgrade;
  buildUrl = "${cfg.instance}/job/${cfg.project}/${cfg.jobset}/${cfg.job}/latest";
  cached-nixos-rebuild = pkgs.writeShellApplication {
    name = "cached-nixos-rebuild";
    runtimeInputs = with pkgs; [
      config.nix.package.out
      config.programs.ssh.package
      coreutils
      curl
      gitMinimal
      gnutar
      gzip
      jq
      nvd
    ];
    text = ''
      action="''${1:-build}"
      profile="/nix/var/nix/profiles/system"
      current="/run/current-system"
      path="$(curl -sLH 'accept: application/json' ${buildUrl} | jq -r '.buildoutputs.out.path')"

      echo "Building $path" >&2
      nix build --no-link "$path"

      if [ "$action" == "diff" ]; then
        nvd --color=always diff "$current" "$path"
      fi

      if [ "$action" == "switch" ] || [ "$action" == "test" ]; then
        if [ "$(readlink -f "$current")" == "$path" ]; then
          echo "Already running $path" >&2
          exit 0
        fi
        echo "Activating configuration" >&2
        nvd --color=always diff "$current" "$path"
        "$path/bin/switch-to-configuration" test
      fi

      if [ "$action" == "switch" ] || [ "$action" == "boot" ]; then
        if [ "$(readlink -f "$profile")" == "$path" ]; then
          echo "Already set to boot $path" >&2
          exit 0
        fi
        echo "Setting profile" >&2
        nix build --no-link --profile "$profile" "$path"

        echo "Adding to bootloader" >&2
        "$path/bin/switch-to-configuration" boot
      fi
    '';
  };
in {
  options = {
    system.hydraAutoUpgrade = {
      enable = lib.mkEnableOption "periodic hydra-based auto upgrade";
      operation = lib.mkOption {
        type = lib.types.enum ["switch" "boot"];
        default = "switch";
      };
      dates = lib.mkOption {
        type = lib.types.str;
        default = "04:40";
        example = "daily";
      };

      instance = lib.mkOption {
        type = lib.types.str;
        example = "https://hydra.m7.rs";
      };
      project = lib.mkOption {
        type = lib.types.str;
        example = "nix-config";
      };
      jobset = lib.mkOption {
        type = lib.types.str;
        example = "main";
      };
      job = lib.mkOption {
        type = lib.types.str;
        default = config.networking.hostName;
      };

      oldFlakeRef = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = ''
          Current system's flake reference

          If non-null, the service will only upgrade if the new config is newer
          than this one's.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.enable -> !config.system.autoUpgrade.enable;
        message = ''
          hydraAutoUpgrade and autoUpgrade are mutually exclusive.
        '';
      }
    ];
    systemd.services.nixos-upgrade = {
      description = "NixOS Upgrade";
      restartIfChanged = false;
      unitConfig.X-StopOnRemoval = false;
      serviceConfig.Type = "oneshot";

      script = "${lib.getExe cached-nixos-rebuild} ${cfg.operation}";
      startAt = cfg.dates;
      after = ["network-online.target"];
      wants = ["network-online.target"];
    };
    # Make script available for admin usage
    environment.systemPackages = [cached-nixos-rebuild];
  };
}
