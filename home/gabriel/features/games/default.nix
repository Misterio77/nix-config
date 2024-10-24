{pkgs, config, ...}: {
  imports = [
    ./steam.nix
    ./prism-launcher.nix
    ./mangohud.nix
  ];
  home = {
    packages = with pkgs; [gamescope];
    persistence = {
      "/persist/${config.home.homeDirectory}" = {
        allowOther = true;
        directories = [
          "Games"
        ];
      };
    };
  };
}
