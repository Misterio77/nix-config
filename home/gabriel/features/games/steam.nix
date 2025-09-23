{pkgs, ...}: {
  home.packages = [
    (pkgs.steam.override {extraPkgs = p: [p.gamescope];})
    pkgs.gamescope
    pkgs.protontricks
  ];

  home.persistence = {
    "/persist".directories = [
      ".local/share/Steam"
    ];
  };
}
