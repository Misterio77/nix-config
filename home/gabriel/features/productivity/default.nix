{
  imports = [
    ./khal.nix
    ./khard.nix
    ./todoman.nix
    ./vdirsyncer.nix
    ./oama.nix
    ./syncthing.nix

    ./mail.nix
    ./neomutt.nix

    # Pass feature is required
    ../pass
  ];
}
