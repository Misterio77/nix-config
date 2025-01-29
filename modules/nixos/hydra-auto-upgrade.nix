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
        buildUrl = "${cfg.instance}/job/${cfg.project}/${cfg.jobset}/${cfg.job}/latest";
      in
        (lib.optionalString (cfg.oldFlakeRef != null) ''
          eval="$(curl -sLH 'accept: application/json' "${buildUrl}" | jq -r '.jobsetevals[0]')"
          flake="$(curl -sLH 'accept: application/json' "${cfg.instance}/eval/$eval" | jq -r '.flake')"
          echo "New flake: $flake" >&2
          new="$(nix flake metadata "$flake" --json | jq -r '.lastModified')"
          echo "Modified at: $(date -d @$new)" >&2

          echo "Current flake: ${cfg.oldFlakeRef}" >&2
          current="$(nix flake metadata "${cfg.oldFlakeRef}" --json | jq -r '.lastModified')"
          echo "Modified at: $(date -d @$current)" >&2

          if [ "$new" -le "$current" ]; then
            echo "Skipping upgrade, not newer" >&2
            exit 0
          fi
        '')
        + ''
          profile="/nix/var/nix/profiles/system"
          path="$(curl -sLH 'accept: application/json' ${buildUrl} | jq -r '.buildoutputs.out.path')"

          if [ "$(readlink -f "$profile")" = "$path" ]; then
            echo "Already up to date" >&2
            exit 0
          fi

          echo "Building $path" >&2
          nix build --no-link "$path"

          echo "Comparing changes" >&2
          nvd --color=always diff "$profile" "$path"

          echo "Activating configuration" >&2
          "$path/bin/switch-to-configuration" test

          echo "Setting profile" >&2
          nix build --no-link --profile "$profile" "$path"

          echo "Adding to bootloader" >&2
          "$path/bin/switch-to-configuration" boot
        '';

      startAt = cfg.dates;
      after = ["network-online.target"];
      wants = ["network-online.target"];
    };
  };
}
