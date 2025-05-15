{
  pkgs,
  lib,
  ...
}: {
  programs.nix-index.enable = true;

  systemd.user.services.nix-index-database-sync = {
    Unit.Description = "fetch nix-community/nix-index-database";
    Service = {
      Type = "oneshot";
      ExecStart = lib.getExe (
        pkgs.writeShellApplication {
          name = "fetch-nix-index-database";
          runtimeInputs = with pkgs; [
            wget
            coreutils
          ];
          text = ''
            mkdir -p ~/.cache/nix-index
            cd ~/.cache/nix-index
            name="index-${pkgs.stdenv.system}"
            wget -N "https://github.com/nix-community/nix-index-database/releases/download/2025-05-04-033656/$name"
            ln -sf "$name" "files"
          '';
        }
      );
      Restart = "on-failure";
      RestartSec = "5m";
    };
  };
  systemd.user.timers.nix-index-database-sync = {
    Unit.Description = "Automatic github:nix-community/nix-index-database fetching";
    Timer = {
      OnBootSec = "10m";
      OnUnitActiveSec = "24h";
    };
    Install.WantedBy = ["timers.target"];
  };
}
