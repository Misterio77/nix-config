{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.system.hydraAutoUpgrade;
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

      lastModified = lib.mkOption {
        type = lib.types.nullOr lib.types.int;
        default = null;
        description = ''
          Current system's last modified date.

          If non-null, the service will only upgrade if the new config is newer
          than this value.
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

      path = with pkgs; [
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

      script = let
        evalUrl = "${cfg.instance}/jobset/${cfg.project}/${cfg.jobset}/latest-eval";
        buildUrl = "${cfg.instance}/job/${cfg.project}/${cfg.jobset}/${cfg.job}/latest";
      in
        (lib.optionalString (cfg.lastModified != null) ''
          flake="$(curl -sLH 'accept: application/json' ${evalUrl} | jq -r '.flake')"
          echo "Flake: $flake" >&2
          new="$(nix flake metadata "$flake" --json | jq -r '.lastModified')"
          echo "Last modified at: $(date -d @$new)" >&2
          current="${toString cfg.lastModified}"
          if [ "$new" -le "$current" ]; then
            echo "Skipping upgrade, as flake is not newer than current" >&2
            exit 0
          fi
        '')
        + ''
          profile="/nix/var/nix/profiles/system"
          path="$(curl -sLH 'accept: application/json' ${buildUrl} | jq -r '.buildoutputs.out.path')"
          echo "Building $path" >&2
          nix build --no-link "$path"

          echo "Comparing changes" >&2
          nvd diff "$profile" "$path"

          echo "Activating configuration" >&2
          "$path/bin/switch-to-configuration test"

          echo "Setting profile" >&2
          nix build --no-link --profile "$profile" "$path"

          echo "Adding to bootloader" >&2
          "$path/bin/switch-to-configuration boot"
        '';

      startAt = cfg.dates;
      after = ["network-online.target"];
      wants = ["network-online.target"];
    };
  };
}
