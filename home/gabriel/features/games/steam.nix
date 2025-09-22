{pkgs, ...}: let
  steam-with-pkgs = pkgs.steam.override {
    extraPkgs = pkgs: [
      (pkgs.writeShellScriptBin "steamos-session-select" ''
        /usr/bin/env steam -shutdown
      '')
      pkgs.gamescope
    ];
  };
in {
  home.packages = [
    steam-with-pkgs
    pkgs.gamescope
    pkgs.protontricks
  ];

  home.persistence = {
    "/persist".directories = [
      ".local/share/Steam"
    ];
  };
}
