{ pkgs, ... }:
{
  imports = [ ./rgbdaemon_service.nix ];

  home.packages = with pkgs; [
    pastel
  ];
  # Override pastel to master (https://github.com/rust-lang/rust/issues/81654)
  # TODO: remove once pastel upgrades
  nixpkgs.overlays = [
    (self: super: {
      pastel = super.pastel.overrideAttrs (oldAttrs: rec {
        src = super.fetchFromGitHub {
          owner = "sharkdp";
          repo = "pastel";
          rev = "4bed587d13fcf7624d2c8be31eb8b20588c8c5b8";
          sha256 = "1ymzfm90gilbxh88b717rrnm6ylpgzj7h9b8qa34an8452qmzbg8";
        };
        cargoDeps = oldAttrs.cargoDeps.overrideAttrs (_: {
          inherit src;
          outputHash = "14q5k74qy9g1gr5i6f3cs9ms31xm85gpa3yaikhwy0lyavvfk3d6";
        });
      });
    })
  ];

  services.rgbdaemon.enable = true;
}
