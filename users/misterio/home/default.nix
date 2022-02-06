{ config, hostname, persistence, graphical, keys, ... }:

{
  imports =
    [ ./cli ./rice ]
    ++ (if graphical then [ ./desktop-sway ./games ] else [ ])
    ++ (if persistence then [ ./persistence ] else [ ])
    ++ (if keys then [ ./trusted ] else [ ])
    ++ (if hostname == "atlas" then [ ./rgb ] else [ ]);

    home.file."home-config" = {
      target = ".config/nixpkgs";
      source = config.lib.file.mkOutOfStoreSymlink "/dotfiles";
    };
}
