{
  imports = [
    # TODO https://github.com/NixOS/nixpkgs/issues/263504
    # ./khal.nix
    ./khard.nix
    ./todoman.nix
    ./vdirsyncer.nix

    ./mail.nix
    ./neomutt.nix

    # Pass feature is required
    ../pass
  ];
}
