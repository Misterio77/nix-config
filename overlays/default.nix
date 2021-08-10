{ pkgs, lib, ... }:

{
  nixpkgs.overlays = [
    # TODO: Remove when https://github.com/alacritty/alacritty/pull/5313 is merged
    (final: prev: {
      alacritty-reload = prev.alacritty.overrideAttrs (oldAttrs: rec {
        src = prev.fetchFromGitHub {
          owner = "ncfavier";
          repo = "alacritty";
          rev = "5f392c2cb516a5ea198ebb48754c7c42157d21b3";
          sha256 = "sha256-szPB8A8CGqU5Sf7evPOP/2xgWN5IFal4z95Yt44bNsM=";
        };
        cargoDeps = oldAttrs.cargoDeps.overrideAttrs (_: {
          inherit src;
          outputHash = "sha256-jCNkdgSzoiOW+jh/q3jR9SsiVa/MC5iz6nXgXOqQhdc=";
        });
      });
    })
    # TODO: Remove when https://github.com/NixOS/nixpkgs/issues/132941 is fixed
    (final: prev: {
      ethash = prev.ethash.overrideAttrs (oldAttrs: rec {
        src = prev.fetchFromGitHub {
          owner = "chfast";
          repo = "ethash";
          rev = "v0.6.0";
          sha256 = "sha256-N30v9OZwTmDbltPPmeSa0uOGJhos1VzyS5zY9vVCWfA=";
        };
      });
    })
  ];
}
