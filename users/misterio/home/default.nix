{ inputs, lib, config, hostname, persistence, graphical, trusted, ... }:

let inherit (inputs.impermanence.nixosModules.home-manager) impermanence;
in
{
  imports =
    [
      ./cli
      ./rice
      impermanence
    ]
    ++ (if graphical then [ ./desktop-sway ./games ] else [ ])
    ++ (if trusted then [ ./trusted ] else [ ])
    ++ (if hostname == "atlas" then [ ./rgb ] else [ ]);

  home.persistence = lib.mkIf persistence {
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
