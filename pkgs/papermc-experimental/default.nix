{ lib, stdenv, fetchurl, bash, jre }:
let
  mcVersion = "1.18";
  buildNum = "59";
  jar = fetchurl {
    url = "https://papermc.io/api/v2/projects/paper/versions/${mcVersion}/builds/${buildNum}/downloads/paper-${mcVersion}-${buildNum}.jar";
    sha256 = "sha256-/dTjuItVZNcwRsOyeFg4AX9AnO24N+nMtYwzLDLFtzI=";
  };
in stdenv.mkDerivation {
  pname = "papermc";
  version = "${mcVersion}r${buildNum}";

  preferLocalBuild = true;

  dontUnpack = true;
  dontConfigure = true;

  buildPhase = ''
    cat > minecraft-server << EOF
    #!${bash}/bin/sh
    exec ${jre}/bin/java \$@ -jar $out/share/papermc/papermc.jar nogui
  '';

  installPhase = ''
    install -Dm444 ${jar} $out/share/papermc/papermc.jar
    install -Dm555 -t $out/bin minecraft-server
  '';

  meta = {
    description = "High-performance Minecraft Server";
    homepage    = "https://papermc.io/";
    license     = lib.licenses.gpl3Only;
    platforms   = lib.platforms.unix;
  };
}
