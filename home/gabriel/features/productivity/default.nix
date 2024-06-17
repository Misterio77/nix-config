{
  imports = [
    ./khal.nix
    ./khard.nix
    ./todoman.nix
    ./vdirsyncer.nix

    ./mail.nix
    ./neomutt.nix

    # Pass feature is required
    ../pass
  ];
}
