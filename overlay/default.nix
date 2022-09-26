{ inputs, ... }:
let
  # Adds my custom packages
  additions = final: _prev: import ../pkgs/top-level { pkgs = final; };

  # Modifies existing packages
  modifications = final: prev: {
    # === Scoped packages ===
    roundcubePlugins = prev.roundcubePlugins // final.callPackage ../pkgs/roundcube-plugins { };
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
            rev = "0c5ea78e5cce406835beee2423e5afdd00521fcb";
            sha256 = "sha256-IEWC0pvuZki0OzD5+8njhHsGbFenI4dcYEAjU9sHvTM=";
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

    scgit = prev.cgit-pink.overrideAttrs (_oldAttrs: {
      pname = "scgit";
      version = "0.1";
      src = final.fetchFromSourcehut {
        owner = "~misterio";
        repo = "scgit";
        rev = "2d4b8c827f9b5b3422f92144154295009a642dad";
        sha256 = "sha256-bqKWVEDglyNUsf1jM8CmArNJpEC+R7G9Ev6Zr5UP+Ok=";
      };
    });

  };
in
inputs.nixpkgs.lib.composeManyExtensions [ additions modifications ]
