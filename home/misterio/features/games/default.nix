{pkgs, ...}: {
  imports = [
    ./lutris.nix
    ./steam.nix
    ./prism-launcher.nix
  ];
  home = {
    packages = with pkgs; [gamescope];
    persistence = {
      "/persist/home/misterio" = {
        allowOther = true;
        directories = [
          "Games"
        ];
      };
    };
  };
}
