final: prev:
{
  vimPlugins = prev.vimPlugins // {
    nvim-base16 = prev.vimPlugins.nvim-base16.overrideAttrs (oldAttrs: rec {
      patches = (oldAttrs.patches or [ ])
      ++ [ ./nvim-base16-more-highlights.patch ];
    });
    vim-numbertoggle = prev.vimPlugins.vim-numbertoggle.overrideAttrs
      (oldAttrs: rec {
        patches = (oldAttrs.patches or [ ])
        ++ [ ./vim-numbertoggle-command-mode.patch ];
      });
    gemini-vim-syntax = prev.vimUtils.buildVimPlugin {
      pname = "gemini-vim-syntax";
      version = "2021-11-15";
      dontBuild = true;
      src = prev.fetchFromGitea {
        domain = "tildegit.org";
        owner = "sloum";
        repo = "gemini-vim-syntax";
        rev = "596d1f36b386e5b2cc1af4f2f8285134626878d1";
        sha256 = "sha256-4Ma74KdAWtr00NNV0DbDL0SwY6s4d2Ok1HaUvVzCrMA=";
      };
      meta.homepage = "https://tildegit.org/sloum/gemini-vim-syntax";
    };
    vim-syntax-shakespeare = prev.vimUtils.buildVimPlugin rec {
      pname = "vim-syntax-shakespeare";
      version = "2021-12-14";
      dontBuild = true;
      src = prev.fetchFromGitHub {
        owner = "pbrisbin";
        repo = pname;
        rev = "2f4f61eae55b8f1319ce3a086baf9b5ab57743f3";
        sha256 = "sha256-sdCXJOvB+vJE0ir+qsT/u1cHNxrksMnqeQi4D/Vg6UA=";
      };
      meta.homepage = "https://github.com/pbrisbin/${pname}";
    };
  };

  # Update openrgb
  openrgb = prev.openrgb.overrideAttrs (oldAttrs: rec {
    buildInputs = (oldAttrs.buildInputs or [ ]) ++ [ prev.mbedtls ];
    version = "master";
    src = prev.fetchFromGitLab {
      owner = "CalcProgrammer1";
      repo = "OpenRGB";
      rev = "e4692cb5625fbc9634742d7043283f8bffa21bce";
      sha256 = "sha256-+t3TfeqMvmj5T3GpbbCZ5toqJYZpRkvX4/TBN76KwkU=";
    };
  });

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

  # Spawn terminal with xdg-open, from https://gitlab.freedesktop.org/xdg/xdg-utils/-/issues/84
  # Rebuilds a lot of stuff, sigh
  xdg-utils = prev.xdg-utils.overrideAttrs (oldAttrs: rec {
    patches = (oldAttrs.patches or [ ]) ++ [ ./xdg-open-terminal.patch ];
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
