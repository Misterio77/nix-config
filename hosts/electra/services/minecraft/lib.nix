{ pkgs }:
let
  remarshal = "${pkgs.remarshal}/bin/remarshal";
in
rec {
  toJSONFile = expr: builtins.toFile "expr" (builtins.toJSON expr);
  toYAMLFile = expr: pkgs.runCommand "expr.yaml" { } ''
    ${remarshal} -i ${toJSONFile expr} -o $out -if json -of yaml
  '';
  toTOMLFile = expr: pkgs.runCommand "expr.toml" { } ''
    ${remarshal} -i ${toJSONFile expr} -o $out -if json -of toml
  '';
  aikarFlags = memory: "-Xms${memory} -Xmx${memory} -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1";
  proxyFlags = memory: "-Xms${memory} -Xmx${memory} -XX:+UseG1GC -XX:G1HeapRegionSize=4M -XX:+UnlockExperimentalVMOptions -XX:+ParallelRefProcEnabled -XX:+AlwaysPreTouch -XX:MaxInlineLevel=15";
  mkMCServer = { pname ? "minecraft-server", version ? "1.0", url, sha256 ? pkgs.lib.fakeSha256 }:
    pkgs.stdenv.mkDerivation {
      inherit pname version;
      src = pkgs.fetchurl { inherit url sha256; };

      preferLocalBuild = true;
      dontUnpack = true;
      installPhase = ''
        mkdir -p $out/bin $out/lib/minecraft
        cp -v $src $out/lib/minecraft/server.jar
        cat > $out/bin/minecraft-server << EOF
        #!/bin/sh
        exec ${pkgs.jre_headless}/bin/java \$@ -jar $out/lib/minecraft/server.jar nogui
        EOF
        chmod +x $out/bin/minecraft-server
      '';
    };

}
