{ inputs, lib, username, persistence, desktop, features, ... }:

let
  inherit (lib) optional mkIf;
  inherit (builtins) map pathExists filter;
in
{
  imports = [
    ./cli
    ./rice
    inputs.impermanence.nixosModules.home-manager.impermanence
  ]
  # Import features that have modules
  ++ filter pathExists (map (feature: ./${feature}) features)
  # Import chosen desktop
  ++ optional (desktop != null) ./desktop/${desktop};

  systemd.user.startServices = "sd-switch";
  programs = {
    home-manager.enable = true;
    git.enable = true;
  };

  home = {
    inherit username;
    stateVersion = "22.05";
    homeDirectory = "/home/${username}";
    persistence = mkIf persistence {
      "/persist/home/misterio" = {
        directories = [
          "Documents"
          "Downloads"
          "Pictures"
          "Videos"
        ];
        allowOther = true;
      };
    };
  };
}
