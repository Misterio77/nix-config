{ inputs, lib, username, persistence, features, ... }: {
  imports = [
    ./cli
    ./rice
    inputs.impermanence.nixosModules.home-manager.impermanence
  ]
  # Import features that have modules
  ++ builtins.filter builtins.pathExists (map (feature: ./${feature}) features);

  systemd.user.startServices = "sd-switch";
  programs = {
    home-manager.enable = true;
    git.enable = true;
  };

  home = {
    inherit username;
    stateVersion = "22.05";
    homeDirectory = "/home/${username}";
    sessionVariables = {
      NIX_CONFIG = "experimental-features = nix-command flakes repl-flakes";
    };
    persistence = lib.mkIf persistence {
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
