{ lib, stdenvNoCC, fetchurl, jre, jq, moreutils, curl, runCommand }:

let
  fetchPackwizPack =
    { pname ? "packwiz-pack"
    , version ? ""
    , url
    , packHash ? lib.fakeHash
    , side ? "server"
    , manifestHash ? lib.fakeHash
    , manifest ? if manifestHash == null then null
      else
        builtins.fetchurl {
          inherit url;
          sha256 = manifestHash;
        }
    , ...
    }@args:

    stdenvNoCC.mkDerivation (finalAttrs: {
      inherit pname version;

      packwizInstaller = fetchurl rec {
        pname = "packwiz-installer";
        version = "0.5.8";
        url = "https://github.com/packwiz/${pname}/releases/download/v${version}/${pname}.jar";
        hash = "sha256-+sFi4ODZoMQGsZ8xOGZRir3a0oQWXjmRTGlzcXO/gPc=";
      };

      packwizInstallerBootstrap = fetchurl rec {
        pname = "packwiz-installer-bootstrap";
        version = "0.0.3";
        url = "https://github.com/packwiz/${pname}/releases/download/v${version}/${pname}.jar";
        hash = "sha256-qPuyTcYEJ46X9GiOgtPZGjGLmO/AjV2/y8vKtkQ9EWw=";
      };

      dontUnpack = true;

      buildInputs = [ jre jq moreutils curl ];

      buildPhase = ''
        java -jar "$packwizInstallerBootstrap" \
          --bootstrap-main-jar "$packwizInstaller" --bootstrap-no-update --no-gui \
          --side "${side}" "${url}"
      '';

      installPhase = ''
        runHook preInstall

        # Fix non-determinism
        rm env-vars -r
        jq -Sc '.' packwiz.json | sponge packwiz.json

        mkdir -p $out
        cp * -r $out/

        runHook postInstall
      '';

      passthru = {
        manifest =
          if manifest == null then null
          else builtins.fromTOML (builtins.readFile manifest);

        addFiles = files:
          let
            drv = fetchPackwizPack args;
          in
          stdenvNoCC.mkDerivation {
            inherit (drv) pname version;
            src = null;
            dontUnpack = true;
            dontConfig = true;
            dontBuild = true;
            dontFixup = true;

            installPhase = ''
              cp -as "${drv}" $out
              chmod u+w -R $out
            '' + lib.concatLines (lib.mapAttrsToList
              (name: file: ''
                mkdir -p "$out/$(dirname "${name}")"
                cp "${file}" "$out/${name}"
              '')
              files
            );

            passthru = { inherit (drv) manifest; };
          };
      };

      dontFixup = true;

      outputHashMode = "recursive";
      outputHashAlgo = "sha256";
      outputHash = packHash;
    } // args);
in
fetchPackwizPack
