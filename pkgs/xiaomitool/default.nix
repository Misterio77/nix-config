{ lib, stdenv, fetchFromGitHub, makeWrapper, gradle_6, jdk11, perl, writeText }:
let
  pname = "xiaomitoolv2";
  version = "unstable-2021-03-25";
  jdk = jdk11;
  gradle = gradle_6;

  src = fetchFromGitHub {
    owner = "francescotescari";
    repo = pname;
    rev = "256679c6061fb2ffcda7fe59caa60a9a3d04517d";
    sha256 = "sha256-QffTGyv+JCF0Phz5GgLLs8gtypYIjZ9MPNO57ksFWNw=";
  };

  patches = [ ./fix-captcha.patch ./update-api-params.patch ];

  deps = stdenv.mkDerivation {
    pname = "${pname}-deps";
    inherit src patches version;

    nativeBuildInputs = [ gradle jdk perl ];

    buildPhase = ''
      export GRADLE_USER_HOME=$(mktemp -d)
      gradle --no-daemon --info build
    '';

    # Mavenize dependency paths
    # e.g. org.codehaus.groovy/groovy/2.4.0/{hash}/groovy-2.4.0.jar -> org/codehaus/groovy/groovy/2.4.0/groovy-2.4.0.jar
    installPhase = ''
      find $GRADLE_USER_HOME/caches/modules-2 -type f -regex '.*\.\(jar\|pom\)' \
        | perl -pe 's#(.*/([^/]+)/([^/]+)/([^/]+)/[0-9a-f]{30,40}/([^/\s]+))$# ($x = $2) =~ tr|\.|/|; "install -Dm444 $1 \$out/$x/$3/$4/$5" #e' \
        | sh
    '';

    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    # outputHash = "sha256-85U9qZswLHt3csgPf0N4/BtVF94I+An4OGklKs0Xvac=";
  };

  # Point to our local deps repo
  gradleInit = writeText "init.gradle" ''
    settingsEvaluated { settings ->
      settings.pluginManagement {
        repositories {
          clear()
          maven { url '${deps}' }
        }
      }
    }
    logger.lifecycle 'Replacing Maven repositories with ${deps}...'
    gradle.projectsLoaded {
      rootProject.allprojects {
        buildscript {
          repositories {
            clear()
            maven { url '${deps}' }
          }
        }
        repositories {
          clear()
          maven { url '${deps}' }
        }
      }
    }
  '';
in

stdenv.mkDerivation {
  inherit pname version src patches;

  nativeBuildInputs = [ gradle jdk makeWrapper ];

  buildPhase = ''
    runHook preBuild

    export GRADLE_USER_HOME=$(mktemp -d)
    gradle --offline --no-daemon --info --init-script ${gradleInit} distTar

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm644 build/libs/XiaomiToolV2.jar $out/lib/xiaomitool.jar

    mkdir -p $out
    tar xf build/distributions/XiaomiToolV2.tar --strip-components=1 --directory $out/

    wrapProgram $out/bin/xiaomitool \
      --set JAVA_HOME "${jdk}"

    runHook postInstall
  '';
}
