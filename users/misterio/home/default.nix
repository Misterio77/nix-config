{ pkgs, lib, hostname, persistence, graphical, keys, colorscheme, wallpaper, ... }:

{
  imports =
    [ ./cli ./rice ]
    ++ (if graphical then [ ./desktop-sway ./games ] else [ ])
    ++ (if persistence then [ ./persistence ] else [ ])
    ++ (if keys then [ ./trusted ] else [ ])
    ++ (if hostname == "atlas" then [ ./rgb ] else [ ]);
}
