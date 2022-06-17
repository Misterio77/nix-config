{ inputs, ... }: final: prev:
let
  inherit (inputs.nix-colors.lib-contrib { pkgs = final; }) gtkThemeFromScheme;
  inherit (inputs.nix-colors) colorSchemes;
  inherit (builtins) mapAttrs;
  inherit (final) fetchFromGitHub;
in
{
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
        src = fetchFromGitHub {
          owner = "hqurve";
          repo = "vim-nix";
          rev = "26abd9cb976b5f4da6da02ee81449a959027b958";
          sha256 = "sha256-7TDW6Dgy/H7PRrIvTMpmXO5/3K5F1d4p3rLYon6h6OU=";
        };
      });
  } // import ../pkgs/vim-plugins { pkgs = final; };

  # ddclient with gandi support
  ddclient = prev.ddclient.overrideAttrs (_oldAttrs: rec {
    version = "3.10.0_2";
    src = fetchFromGitHub {
      owner = "ddclient";
      repo = "ddclient";
      rev = "v${version}";
      sha256 = "sha256-oWWdJ358k2gFCoziU5y+T/e/XnmcFABhMf4YlD0qhko=";
    };
    buildInputs = with final.perlPackages; [ IOSocketInet6 IOSocketSSL JSONPP ];
    postPatch = ''
      touch Makefile.PL
    '';
    nativeBuildInputs = [ final.autoreconfHook ];
    installPhase = ''
      runHook preInstall

      preConfigure
      install -Dm755 ddclient $out/bin/ddclient
      install -Dm644 -t $out/share/doc/ddclient COP* README.* ChangeLog.md

      runHook postInstall
    '';
  });

  # Don't launch discord when using discocss
  discocss = prev.discocss.overrideAttrs (oldAttrs: rec {
    patches = (oldAttrs.patches or [ ]) ++ [ ./discocss-no-launch.patch ];
  });

  xdg-utils = prev.xdg-utils.overrideAttrs (oldAttrs: rec {
    patches = (oldAttrs.patches or [ ]) ++ [ ./xdg-open-spawn-terminal.diff ];
  });

  # Fixes https://todo.sr.ht/~scoopta/wofi/174
  wofi = prev.wofi.overrideAttrs (oldAttrs: rec {
    patches = (oldAttrs.patches or [ ]) ++ [ ./wofi-run-shell.patch ];
  });

  generated-gtk-themes = mapAttrs (_: scheme: gtkThemeFromScheme { inherit scheme; }) colorSchemes;

} // import ../pkgs { pkgs = final; }
