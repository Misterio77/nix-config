{
  description = "Foo bar";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.05";
  };

  outputs = { self, nixpkgs, nix-colors }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      pkgsFor = nixpkgs.legacyPackages;
    in
    rec {
      packages = forAllSystems (system: rec {
        default = site;
        site = pkgsFor.${system}.callPackage ./. { };
        serve = pkgsFor.${system}.writeShellScriptBin "serve" ''
          echo "Serving on http://localhost:4000"
          ${pkgsFor.${system}.webfs}/bin/webfsd -p 4000 -F -f index.html -r ${site}
        '';
      });

      apps = forAllSystems (system: {
        default = {
          type = "app";
          program = "${packages.${system}.serve}/bin/serve";
        };
      });

      hydraJobs = {
        x86_64-linux.site = packages.x86_64-linux.site;
      };
    };
}
