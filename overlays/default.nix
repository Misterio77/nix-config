{ pkgs, lib, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      alacritty-reload = pkgs.alacritty.overrideAttrs (oldAttrs: rec {
        src = pkgs.fetchFromGitHub {
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
  ];
}
