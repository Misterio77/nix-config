{ pkgs, ... }:
# Uma forma simples, porem gambiarrenta, de rodar o forge
# Esse script roda o instalador, e depois a jar :p
# O diretório fica todo sujo, mas é suave

let
  version = "1.16.5-36.2.34";
  installer = pkgs.fetchurl {
    pname = "forge-installer";
    inherit version;
    url = "https://maven.minecraftforge.net/net/minecraftforge/forge/${version}/forge-${version}-installer.jar";
    hash = "sha256-U7c9u8xIbzhybnbOkjsTOBBEmEyDx2KEfHGTNA+XEw8=";
  };
  java = "${pkgs.jre8}/bin/java";
in
pkgs.writeShellScriptBin "server" ''
  if ! [ -e "forge-${version}.jar" ]; then
    ${java} -jar ${installer} --installServer
  fi
  exec ${java} $@ -jar forge-${version}.jar nogui
''
