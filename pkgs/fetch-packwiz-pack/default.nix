{ lib, stdenvNoCC, fetchurl, jre_headless, jq, moreutils, curl, cacert }:

let
  fetchPackwizPack =
    { pname ? "packwiz-pack"
    , version ? ""
    , url
    , packHash ? ""
      # Either 'server' or 'both' (to get client mods as well)
    , side ? "server"

      # The derivation passes through a 'manifest' expression, that includes
      # useful metadata (such as MC version).
      # By default, if you access it, IFD will be used. If you want to use
      # 'manifest' without IFD, you can alternatively pass a manifestHash, that
      # allows us to fetch it with builtins.fetchurl (does not output a
      # derivation).
    , manifestHash ? null
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

      buildInputs = [ jre_headless jq moreutils curl cacert ];

      buildPhase = ''
        curl -L "${url}" > pack.toml
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

      passthru =
        let
          drv = fetchPackwizPack args;
        in
        {
          # Pack manifest as a nix expression
          # If manifestHash is not null, then we can do this without IFD.
          # Otherwise, fallback to IFD.
          manifest = lib.importTOML (
            if manifestHash != null then
              builtins.fetchurl
                {
                  inherit url;
                  sha256 = manifestHash;
                }
            else
              "${drv}/pack.toml"
          );

          # Adds an attribute set of files to the derivation.
          # Useful to add server-specific mods not part of the pack.
          addFiles = files:
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
              meta = drv.meta or { };
            };
        };

      dontFixup = true;

      outputHashMode = "recursive";
      outputHashAlgo = "sha256";
      outputHash = packHash;
    } // args);
in
fetchPackwizPack
