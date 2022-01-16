final: prev:
{
  vimPlugins = prev.vimPlugins // {
    vim-numbertoggle = prev.vimPlugins.vim-numbertoggle.overrideAttrs
      (oldAttrs: rec {
        patches = (oldAttrs.patches or [ ])
        ++ [ ./vim-numbertoggle-command-mode.patch ];
      });
  } // import ../pkgs/vim-plugins { pkgs = final; };

  todoman = prev.todoman.overrideAttrs (oldAttrs: rec {
    patches = (oldAttrs.patches or [ ]) ++ [ ./todoman-kwargs-crash.patch ];
  });

  # Add my patch for supporting sourcehut
  /*
  nixUnstable = prev.nixUnstable.overrideAttrs (oldAttrs: rec {
    patches = (oldAttrs.patches or [ ]) ++ [ ./nix-sourcehut.patch ];
  });
  */

  # Don't launch discord when using discocss
  discocss = prev.discocss.overrideAttrs (oldAttrs: rec {
    patches = (oldAttrs.patches or [ ]) ++ [ ./discocss-no-launch.patch ];
  });

  # Fixes https://todo.sr.ht/~scoopta/wofi/174
  wofi = prev.wofi.overrideAttrs (oldAttrs: rec {
    patches = (oldAttrs.patches or [ ]) ++ [ ./wofi-run-shell.patch ];
  });

  # Add suggestion for nix shell instead of nix-env
  nix-index-unwrapped = prev.nix-index-unwrapped.overrideAttrs (oldAttrs: rec {
    patches = (oldAttrs.patches or [ ]) ++ [ ./nix-index-new-command.patch ];
  });
} // import ../pkgs { pkgs = final; }
