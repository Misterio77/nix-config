{ pkgs, config, ... }: {
  home.packages = [ pkgs.steam ];
  home.persistence = {
    "/persist/home/layla" = {
      allowOther = true;
      directories = [ ".config/unity3d/IronGate/Valheim" ".local/share/Steam" ];
      files = [ ".steam/steam.token" ".steam/registry.vdf" ];
    };
  };
}
