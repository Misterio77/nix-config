{ lib, fetchFromGitHub, callPackage, makeWrapper, jdk11, gradle_6 }:
let
  buildGradle = callPackage ./gradle-env.nix { };
in
buildGradle rec {
  pname = "xiaomitoolv2";
  version = "unstable-2021-03-25";

  envSpec = ./gradle-env.json;

  src = fetchFromGitHub {
    owner = "francescotescari";
    repo = pname;
    rev = "256679c6061fb2ffcda7fe59caa60a9a3d04517d";
    sha256 = "sha256-QffTGyv+JCF0Phz5GgLLs8gtypYIjZ9MPNO57ksFWNw=";
  };

  buildInputs = [ makeWrapper ];

  patches = [ ./fix-captcha.patch ./update-api-params.patch ];

  gradleFlags = [ "installDist"];
  gradlePackage = gradle_6;

  installPhase = ''
    find .
    mkdir -p $out
    cp -r build/install/XiaomiToolV2/* $out/
    mv $out/bin/{XiaomiToolV2,xiaomitool}
    rm $out/bin/XiaomiToolV2.bat
  '';

  postFixup = ''
  wrapProgram $out/bin/xiaomitool \
    --set JAVA_HOME "${jdk11}"
  '';

}
