{
  # Adds my custom packages
  additions = final: _prev: import ../pkgs { pkgs = final; };

  # My wallpapers
  wallpapers = final: prev: {
    wallpapers = final.callPackage ../pkgs/wallpapers { };
  };

  # Modifies existing packages
  modifications = final: prev: {
    vimPlugins = prev.vimPlugins // {
      vim-numbertoggle = prev.vimPlugins.vim-numbertoggle.overrideAttrs
        (oldAttrs: rec {
          patches = (oldAttrs.patches or [ ])
            ++ [ ./vim-numbertoggle-command-mode.patch ];
        });
    } // final.callPackage ../pkgs/vim-plugins { };

    tree-sitter-grammars = prev.tree-sitter-grammars // {
      tree-sitter-nix = prev.tree-sitter-grammars.tree-sitter-nix.overrideAttrs (oldAttrs: {
        src = final.fetchFromGitHub {
          owner = "cstrahan";
          repo = "tree-sitter-nix";
          rev = "1b69cf1fa92366eefbe6863c184e5d2ece5f187d";
          sha256 = "sha256-JaJRikijCXnKAuKA445IIDaRvPzGhLFM29KudaFsSVM=";
        };
      });
    };

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
        rev = "2cd05c95827fb94740e876733dc6f7fe88340de2";
        sha256 = "sha256-95mRJ3ZCSkLHqehFQdwM2BY0h+YDhohwpnRiF6/lZtA=";
      };
    });

  };
}
