{ lib, stdenv, fetchurl, nixosTests, jre_headless }:
let
  /*
  version = "1.19.3-367";
  url = "https://api.papermc.io/v2/projects/paper/versions/1.19.3/builds/367/downloads/paper-1.19.3-367.jar";
  sha256 = "sha256-8OhbQFoLsuJJK38a1PEAdwJIZUSEw3l6jTs/5w4EHko=";
  */
  version = "1.19.3-R0.1";
  url = "https://files.m7.rs/paper-bundler-1.19.3-R0.1-SNAPSHOT-reobf.jar";
  sha256 = "sha256-6mInBOGwmsEegSZVC4VjvWM0/kGGS2yugl2dtaW9YQ8=";
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
