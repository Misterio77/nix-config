{ pkgs, features, lib, ... }: {
  programs.mangohud.enable = true;
  home.packages = with pkgs; [ nur.repos.dukzcry.gamescope steam ];

  home.persistence = lib.mkIf (builtins.elem "persistence" features) {
    "/data/games/misterio" = {
      allowOther = true;
      directories = [
        "Games/Steam"
        ".local/share/Steam"

        ".factorio"
        ".config/Hero_Siege"
        ".config/unity3d/Berserk Games/Tabletop Simulator"
        ".config/unity3d/IronGate/Valheim"
        ".local/share/Tabletop Simulator"
        ".local/share/Paradox Interactive"
        ".paradoxlauncher"
      ];
      files = [ ".steam/steam.token" ".steam/registry.vdf" ];
    };
  };
}
