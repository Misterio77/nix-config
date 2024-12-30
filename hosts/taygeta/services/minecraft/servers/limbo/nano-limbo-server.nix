{
  stdenv,
  fetchurl,
  jre_headless,
}:
stdenv.mkDerivation rec {
  pname = "nano-limbo";
  version = "1.8.1";
  src = fetchurl {
    url = "https://github.com/Nan1t/NanoLimbo/releases/download/v${version}/NanoLimbo-${version}-all.jar";
    sha256 = "sha256-HA7PFV+TiJYKT9XUuI0117OJNaCskUYXuVVLi4jXVsM=";
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

  meta.mainProgram = pname;
}
