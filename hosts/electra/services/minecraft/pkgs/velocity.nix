{ lib, stdenv, fetchurl, nixosTests, jre_headless }:
let
  version = "207";
  url = "https://api.papermc.io/v2/projects/velocity/versions/3.1.2-SNAPSHOT/builds/207/downloads/velocity-3.1.2-SNAPSHOT-207.jar";
  sha256 = "sha256-gjOTQFQTQT2uH3yDyJhR2+dDnnGcwxeToVuarZUaQxU=";
in
stdenv.mkDerivation {
  pname = "velocity";
  inherit version;

  src = fetchurl { inherit url sha256; };

  preferLocalBuild = true;

  installPhase = ''
    mkdir -p $out/bin $out/lib/minecraft
    cp -v $src $out/lib/minecraft/server.jar
    cat > $out/bin/minecraft-server << EOF
    #!/bin/sh
    exec ${jre_headless}/bin/java \$@ -jar $out/lib/minecraft/server.jar nogui
    EOF
    chmod +x $out/bin/minecraft-server
  '';

  dontUnpack = true;

  meta = with lib; {
    description = "Velocity server proxy";
    homepage = "https://velocity.io";
    platforms = platforms.unix;
  };
}
