{config, ...}: {
  programs.steam = {
    enable = true;
    gamescopeSession = {
      enable = true;
      steamArgs = ["-tenfoot"];
    };
  };

  systemd.user.services.steam-gamescope-reaper = {
    description = "Monitor and handle steam gamescope session exit requests";
    wantedBy = ["steam-gamescope-session.target"];
    partOf = ["steam-gamescope-session.target"];
    after = ["steam-gamescope-session.target"];

    script = ''
      while sleep 5; do
        if tail -n 10 ~/.steam/steam/logs/console-linux.txt | grep "The name org.freedesktop.DisplayManager was not provided by any .service files$" -q; then
          echo "Exit request detected, sending shutdown signal"
          ${config.programs.steam.package}/bin/steam -shutdown
        fi
      done
    '';
  };
}
