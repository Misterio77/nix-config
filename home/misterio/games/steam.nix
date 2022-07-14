{ config, persistence, lib, ... }: {
  home.persistence = lib.mkIf persistence {
    "/persist/games/misterio" = {
      allowOther = true;
      directories = [
        ".factorio"
        ".config/Hero_Siege"
        ".config/unity3d/Berserk Games/Tabletop Simulator"
        ".config/unity3d/IronGate/Valheim"
        ".local/share/Tabletop Simulator"
        ".local/share/Paradox Interactive"
        ".paradoxlauncher"
        {
          path = ".local/share/Steam";
          method = "symlink";
        }
      ];
    };
  };
}
