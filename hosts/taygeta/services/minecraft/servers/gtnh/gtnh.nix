{
  lib,
  stdenvNoCC,
  fetchzip,
  jre_headless,
  groovy,
  makeWrapper,
  writeShellScript,
  # Setup mods/config files during startup
  setupFiles ? true,
  ...
}: let
  # Groovy script to parse meta inf from jar
  readMetaInf = /* groovy */ ''
    import java.net.URL
    import java.io.File
    import java.util.jar.Attributes.Name

    jarPath = args[0]
    pathPrefix = args[1]
    jar = new URL("jar:file:" + new File(jarPath).getAbsolutePath()+ "!/")
    attributes =  jar.openConnection().getManifest().getMainAttributes()
    println(attributes.get(Name.MAIN_CLASS))
    println(attributes.get(Name.CLASS_PATH).split(' ').collect{"$pathPrefix/$it"}.join(':'))
  '';
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

  nativeBuildInputs = [makeWrapper groovy];

  preStart = writeShellScript "gtnh-prestart" ''
    out=$1

    # Link stuff
    for name in "mods" "server-icon.png"; do
      realpath="$(realpath -m "$name" || true)"
      if [[ "$realpath" == "/nix/store/"*"/lib/$name" && "$realpath" != "$out/lib/$name" ]]; then
        echo "$name out of date or broken. Cleaning up."
        unlink "$name"
      fi
      if ! [[ -e "$name" ]]; then
        echo "$name missing. Linking it from $out/lib."
        ln -s "$out/lib/$name" .
      fi
    done
    # Copy stuff
    for name in "config" "serverutilities" "server.properties"; do
      if ! [[ -e "$name" ]]; then
        echo "$name missing. Copying it from $out/lib."
        cp -rL "$out/lib/$name" .
        chmod +w "$name" -R
      fi
    done
  '';

  installPhase = ''
    mkdir $out
    ln -s $src $out/lib
    lwjgl3ify="$out/lib/lwjgl3ify-forgePatches.jar"
    # Get main_class and class_path from lwjgl3ify jar
    { read main_class; read class_path; } < <(groovy -e ${lib.escapeShellArg readMetaInf} $lwjgl3ify $out/lib)
    # Create bin
    makeWrapper ${lib.getExe jre_headless} $out/bin/gt-new-horizons \
      ${lib.optionalString setupFiles ''--run "$preStart $out"''} \
      --append-flags "@$out/lib/java9args.txt -cp $lwjgl3ify:$class_path $main_class nogui"
  '';
}
