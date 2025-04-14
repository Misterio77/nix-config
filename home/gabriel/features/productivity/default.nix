{
  imports = [
    # TODO: broken
    # ./khal.nix
    ./khard.nix
    ./todoman.nix
    ./vdirsyncer.nix
    ./syncthing.nix

    ./mail.nix
    ./neomutt.nix

    # Pass feature is required
    ../pass
  ];
}
