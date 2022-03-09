final: prev:
{
  vimPlugins = prev.vimPlugins // {
    vim-numbertoggle = prev.vimPlugins.vim-numbertoggle.overrideAttrs
      (oldAttrs: rec {
        patches = (oldAttrs.patches or [ ])
        ++ [ ./vim-numbertoggle-command-mode.patch ];
      });
    vim-nix = prev.vimPlugins.vim-nix.overrideAttrs
      (oldAttrs: rec {
        version = "2022-02-20";
        src = final.fetchFromGitHub {
          owner = "hqurve";
          repo = "vim-nix";
          rev = "26abd9cb976b5f4da6da02ee81449a959027b958";
          sha256 = "sha256-7TDW6Dgy/H7PRrIvTMpmXO5/3K5F1d4p3rLYon6h6OU=";
        };
      });
  } // import ../pkgs/vim-plugins { pkgs = final; };

  todoman = prev.todoman.overrideAttrs (oldAttrs: rec {
    patches = (oldAttrs.patches or [ ]) ++ [ ./todoman-kwargs-crash.patch ];
  });

  ddclient = prev.ddclient.overrideAttrs (oldAttrs: rec {
    version = "master";

    src = final.fetchFromGitHub {
      owner = "ddclient";
      repo = "ddclient";
      rev = "17160fb016448106d21742e53404f9e7a16348fc";
      sha256 = "sha256-yyYp6+4zfV2OuQFJ8/YqUy/7wqAAyRx/ihHGdZEA9Mc=";
    };

    buildInputs = with final.perlPackages; [ IOSocketSSL DigestSHA1 DataValidateIP JSONPP IOSocketInet6 final.perl ];
    nativeBuildInputs = [ final.autoreconfHook ];

    preConfigure = ''
      ./autogen
      touch Makefile.PL
    '';
    installPhase = ''
      runHook preInstall

      install -Dm755 ddclient $out/bin/ddclient
      install -Dm644 -t $out/share/doc/ddclient COPY* README.* ChangeLog.md

      runHook postInstall
    '';
  });

  # Update to commit that includes my sourcehut patch (can't waitt!!!)
  nixUnstable = prev.nixUnstable.overrideAttrs (oldAttrs: rec {
    src = final.fetchFromGitHub {
      owner = "NixOS";
      repo = "nix";
      rev = "92b8d4d8861b908a7ec500526a84155c597d6d2b";
      sha256 = "sha256-mdwznVHawjYvav6/fkBnwV90ItwHapSjPhNafh37mV4=";
    };
  });

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
