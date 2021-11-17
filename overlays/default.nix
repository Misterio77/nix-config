{ pkgs, lib, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      amdgpu-clocks = prev.callPackage ../pkgs/amdgpu-clocks { };
      preferredplayer = prev.callPackage ../pkgs/preferredplayer { };
      rgbdaemon = prev.callPackage ../pkgs/rgbdaemon { };
      sistemer-bot = prev.callPackage ../pkgs/sistemer-bot { };
      projeto-bd = prev.callPackage ../pkgs/projeto-bd { };
      soundwire = prev.libsForQt5.callPackage ../pkgs/soundwire { };
      wallpapers = prev.callPackage ../pkgs/wallpapers { };
      zenity-askpass = prev.callPackage ../pkgs/zenity-askpass { };

      setscheme = prev.callPackage ../pkgs/setscheme { };
      setwallpaper = prev.callPackage ../pkgs/setwallpaper { };

      setscheme-wofi = prev.callPackage ../pkgs/setscheme-wofi {
        inherit (final.gnome) zenity;
      };
      setwallpaper-wofi = prev.callPackage ../pkgs/setwallpaper-wofi {
        inherit (final.gnome) zenity;
      };

      vimPlugins = prev.vimPlugins // {
        nvim-base16 = prev.vimPlugins.nvim-base16.overrideAttrs (oldAttrs: rec {
          patches = (oldAttrs.patches or [ ]) ++ [ ./nvim-base16-more-highlights.patch ];
        });
        vim-numbertoggle = prev.vimPlugins.vim-numbertoggle.overrideAttrs (oldAttrs: rec {
          patches = (oldAttrs.patches or [ ]) ++ [ ./vim-numbertoggle-command-mode.patch ];
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
      };

      pass-wofi = prev.callPackage ../pkgs/pass-wofi {
        pass = final.pass.withExtensions (exts: [ exts.pass-otp ]);
      };

      # Link kitty to xterm (to fix crappy drun behaviour)
      kitty = prev.kitty.overrideAttrs (oldAttrs: rec {
        postInstall = (oldAttrs.postInstall or " ") + ''
          ln -s $out/bin/kitty $out/bin/xterm
        '';
      });

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
      nix_2_4 = prev.nix_2_4.overrideAttrs (oldAttrs: rec {
        patches = (oldAttrs.patches or [ ]) ++ [ ./nix-sourcehut.patch ];
      });

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
        patches = (oldAttrs.patches or [ ])
          ++ [ ./nix-index-new-command.patch ];
      });

    })
  ];
}
