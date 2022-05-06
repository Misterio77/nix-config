{ inputs, lib, games, config, rgb, persistence, desktop, trusted, ... }:

let
  inherit (inputs.impermanence.nixosModules.home-manager) impermanence;
  inherit (lib) optional mkIf;
in
{
  imports =
    [
      ./cli
      ./rice
      impermanence
    ]
    ++ optional (null != desktop) ./desktop-${desktop}
    ++ optional games ./games
    ++ optional trusted ./trusted
    ++ optional rgb ./rgb;

  home.persistence = mkIf persistence {
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

  # Symlink /dotfiles to .config/nixpkgs, so i can use `home-manager switch`
  home.file."home-config" = {
    target = ".config/nixpkgs";
    source = config.lib.file.mkOutOfStoreSymlink "/dotfiles";
  };
}
