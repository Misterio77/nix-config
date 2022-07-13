{
  description = "Foo Bar Document";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
  };

  outputs = { self, nixpkgs }:
    let
      inherit (nixpkgs.lib) genAttrs systems;
      forAllSystems = genAttrs systems.flakeExposed;
      pkgsFor = forAllSystems (system: import nixpkgs {
        inherit system; overlays = [ self.overlays.default ];
      });
    in
    {
      overlays = rec {
        default = final: prev: {
          foo-bar = prev.callPackage ./. { };
        };
      };

      packages = forAllSystems (s:
        let pkgs = pkgsFor.${s}; in
        rec {
          inherit (pkgs) foo-bar;
          default = foo-bar;
        });

      devShells = forAllSystems (s:
        let pkgs = pkgsFor.${s}; in
        rec {
          foo-bar = pkgs.mkShell {
            inputsFrom = [ pkgs.foo-bar ];
          };
          default = foo-bar;
        });
    };
}
