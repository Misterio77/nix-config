{
  lib,
  stdenvNoCC,
  fetchzip,
  jre_headless,
  makeWrapper,
  ...
}: let
  classPath = lib.concatStringsSep ":" [
    "$out/lib/lwjgl3ify-forgePatches.jar"
    # This list can be found in lwjgl3ify's META-INF/MANIFEST.mf
    "$out/lib/libraries/com/typesafe/akka/akka-actor_2.11/2.3.3/akka-actor_2.11-2.3.3.jar"
    "$out/lib/libraries/com/typesafe/config/1.2.1/config-1.2.1.jar"
    "$out/lib/libraries/org/scala-lang/scala-actors-migration_2.11/1.1.0/scala-actors-migration_2.11-1.1.0.jar"
    "$out/lib/libraries/org/scala-lang/scala-compiler/2.11.1/scala-compiler-2.11.1.jar"
    "$out/lib/libraries/org/scala-lang/plugins/scala-continuations-library_2.11/1.0.2/scala-continuations-library_2.11-1.0.2.jar"
    "$out/lib/libraries/org/scala-lang/plugins/scala-continuations-plugin_2.11.1/1.0.2/scala-continuations-plugin_2.11.1-1.0.2.jar"
    "$out/lib/libraries/org/scala-lang/scala-library/2.11.1/scala-library-2.11.1.jar"
    "$out/lib/libraries/org/scala-lang/scala-parser-combinators_2.11/1.0.1/scala-parser-combinators_2.11-1.0.1.jar"
    "$out/lib/libraries/org/scala-lang/scala-reflect/2.11.1/scala-reflect-2.11.1.jar"
    "$out/lib/libraries/org/scala-lang/scala-swing_2.11/1.0.1/scala-swing_2.11-1.0.1.jar"
    "$out/lib/libraries/org/scala-lang/scala-xml_2.11/1.0.2/scala-xml_2.11-1.0.2.jar"
    "$out/lib/libraries/lzma/lzma/0.0.1/lzma-0.0.1.jar"
    "$out/lib/libraries/net/sfjopt-simple/jopt-simple/4.5/jopt-simple-4.5.jar"
    "$out/lib/libraries/com/google/guava/guava/17.0/guava-17.0.jar"
    "$out/lib/forge-1.7.10-10.13.4.1614-1.7.10-universal.jar"
    "$out/lib/minecraft_server.1.7.10.jar"
  ];
  entryClass = "me.eigenraven.lwjgl3ify.rfb.entry.ServerMain";
in stdenvNoCC.mkDerivation {
  pname = "gt-new-horizons";
  version = "2.7.4";

  src = fetchzip {
    url = "https://downloads.gtnewhorizons.com/ServerPacks/GT_New_Horizons_2.7.4_Server_Java_17-21.zip";
    hash = "sha256-EmjpJl3faXx7/FMKTpKk//q7cm/xNZ3m5fExa3rdB9U=";
    stripRoot = false;
    postFetch = ''
      # Extract IC2 dep to mod folder
      unzip -j $out/mods/industrialcraft-2-2.2.828a-experimental.jar lib/EJML-core-0.26.jar -d $out/mods/ic2/
    '';
  };

  nativeBuildInputs = [makeWrapper];

  installPhase = ''
    mkdir $out
    ln -s $src $out/lib
    # Create bin
    makeWrapper ${lib.getExe jre_headless} $out/bin/gt-new-horizons \
      --append-flags "@$out/lib/java9args.txt -cp ${classPath} ${entryClass} nogui"
  '';
}
