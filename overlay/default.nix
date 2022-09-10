{ inputs, ... }:
let
  # Adds my custom packages
  additions = final: _prev: import ../pkgs/top-level { pkgs = final; };

  # Modifies existing packages
  modifications = final: prev: {
    # === Scoped packages ===
    vimPlugins = prev.vimPlugins // {
      vim-numbertoggle = prev.vimPlugins.vim-numbertoggle.overrideAttrs
        (oldAttrs: rec {
          patches = (oldAttrs.patches or [ ])
            ++ [ ./vim-numbertoggle-command-mode.patch ];
        });
      # Enable language fencing
      vim-nix = prev.vimPlugins.vim-nix.overrideAttrs
        (_oldAttrs: rec {
          version = "2022-02-20";
          src = final.fetchFromGitHub {
            owner = "hqurve";
            repo = "vim-nix";
            rev = "26abd9cb976b5f4da6da02ee81449a959027b958";
            sha256 = "sha256-7TDW6Dgy/H7PRrIvTMpmXO5/3K5F1d4p3rLYon6h6OU=";
          };
        });
    } // final.callPackage ../pkgs/vim-plugins { };

    wallpapers = final.callPackage ../pkgs/wallpapers { };

    # === Top level packages ===

    # Don't launch discord when using discocss
    discocss = prev.discocss.overrideAttrs (oldAttrs: rec {
      patches = (oldAttrs.patches or [ ]) ++ [ ./discocss-no-launch.patch ];
    });

    xdg-utils-spawn-terminal = prev.xdg-utils.overrideAttrs (oldAttrs: rec {
      patches = (oldAttrs.patches or [ ]) ++ [ ./xdg-open-spawn-terminal.diff ];
    });

    # Fixes https://todo.sr.ht/~scoopta/wofi/174
    wofi = prev.wofi.overrideAttrs (oldAttrs: rec {
      patches = (oldAttrs.patches or [ ]) ++ [ ./wofi-run-shell.patch ];
    });

    waybar = prev.waybar.overrideAttrs (oldAttrs: {
      mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
    });

    pfetch = prev.pfetch.overrideAttrs (oldAttrs: {
      version = "unstable-2021-12-10";
      src = final.fetchFromGitHub {
        owner = "dylanaraps";
        repo = "pfetch";
        rev = "a906ff89680c78cec9785f3ff49ca8b272a0f96b";
        sha256 = "sha256-9n5w93PnSxF53V12iRqLyj0hCrJ3jRibkw8VK3tFDvo=";
      };
      # Add term option, rename de to desktop, add scheme option
      patches = (oldAttrs.patches or [ ]) ++ [ ./pfetch.patch ];
    });

    # Sane default values and crash avoidance (https://github.com/k-vernooy/trekscii/pull/1)
    trekscii = prev.trekscii.overrideAttrs (oldAttrs: rec {
      patches = (oldAttrs.patches or [ ]) ++ [ ./trekscii.patch ];
    });

    # Temporary fix for https://github.com/emersion/xdg-desktop-portal-wlr/issues/216
    xdg-desktop-portal-wlr = prev.xdg-desktop-portal-wlr.overrideAttrs (oldAttrs: rec {
      patches = (oldAttrs.patches or [ ]) ++ [ ./fix-xdpw-hyprland-crash.patch ];
    });

    semanticgit = prev.cgit-pink.overrideAttrs (_oldAttrs: {
      pname = "semanticgit";
      version = "0.1";
      src = final.fetchFromSourcehut {
        owner = "~misterio";
        repo = "scgit";
        rev = "09512c00f0a791125fd768d978b793ddada3faef";
        sha256 = "sha256-MOyuKxGXQxZTp7QTlvEaGTkrCpTJY9AoW13KcmmOJxg=";
      };
    });

  };
in
inputs.nixpkgs.lib.composeManyExtensions [ additions modifications ]
