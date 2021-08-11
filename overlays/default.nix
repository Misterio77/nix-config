{ pkgs, lib, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      swayfader = pkgs.stdenv.mkDerivation {
        name = "swayfader";
        src = pkgs.fetchFromGitHub {
          owner = "Misterio77";
          repo = "swayfader";
          rev = "3f18eacb4b43ffd2d8c10a395a3e77bbb40ccee6";
          sha256 = "0x490g1g1vjrybnwna9z00r9i61d5sbrzq7qi7mdq6y94whwblla";
        };
        buildInputs = [ (pkgs.python3.withPackages (ps: [ ps.i3ipc ])) ];
        dontBuild = true;
        dontConfigure = true;
        installPhase = "install -Dm 0755 $src/swayfader.py $out/bin/swayfader";
      };
    })
    (final: prev: {
      rgbdaemon = prev.stdenv.mkDerivation {
        name = "rgbdaemon";
        src = pkgs.fetchFromGitHub {
          owner = "Misterio77";
          repo = "rgbdaemon";
          rev = "4c8ae65f9cd334b0a324ab0b4aedabbbcf617962";
          sha256 = "sha256-ujXFiCflEIq+FOD5X0HO8bFPgXpG0VYbgBXOR5W3tKg=";
        };
        propagatedBuildInputs = with pkgs; [ pastel makeWrapper ];
        dontBuild = true;
        dontConfigure = true;
        installPhase = ''
          install -Dm 0755 $src/rgbdaemon.sh $out/bin/rgbdaemon
        '';
      };
    })
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
