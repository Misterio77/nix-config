{ stdenv, fetchurl, jre_headless }:
stdenv.mkDerivation rec {
  pname = "nano-limbo";
  version = "1.5";
  src = fetchurl {
    url = "https://github.com/Nan1t/NanoLimbo/releases/download/v${version}/NanoLimbo-${version}-all.jar";
    sha256 = "sha256-0zPQNfUEgK0zIdLEUjTGw2N+Nbe8byZfqrkPYBR888Q=";
  };
  preferLocalBuild = true;
  dontUnpack = true;
  installPhase = ''
    mkdir -p $out/bin $out/lib/minecraft
    cp -v $src $out/lib/minecraft/server.jar
    cat > $out/bin/${pname} << EOF
    #!/bin/sh
    exec ${jre_headless}/bin/java \$@ -jar $out/lib/minecraft/server.jar nogui
    EOF
    chmod +x $out/bin/${pname}
  '';
}
