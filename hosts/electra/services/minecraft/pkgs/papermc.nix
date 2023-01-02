{ lib, stdenv, fetchurl, nixosTests, jre_headless }:
let
  version = "1.19.3-367";
  url = "https://api.papermc.io/v2/projects/paper/versions/1.19.3/builds/367/downloads/paper-1.19.3-367.jar";
  sha256 = "sha256-8OhbQFoLsuJJK38a1PEAdwJIZUSEw3l6jTs/5w4EHko=";
in
stdenv.mkDerivation {
  pname = "papermc";
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
    description = "PaperMC server";
    homepage = "https://papermc.io";
    platforms = platforms.unix;
  };
}
