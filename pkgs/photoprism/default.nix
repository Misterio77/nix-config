{ lib, pkgs, stdenv, buildGoModule, fetchFromGitHub, fetchzip, coreutils, fetchurl, darktable, rawtherapee, ffmpeg, libheif, exiftool, nodejs }:

with lib;
let
  version = "220302-0059f429";
  pname = "photoprism";

  inherit (stdenv.hostPlatform) system;

  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
    rev = version;
    sha256 = "sha256-hEA2E5ty9j9BH7DviYh5meao0ot0alPgMoJcplJDRc4=";
  };

  fetchModel = { name, sha256 }:
    fetchzip {
      inherit sha256;
      url = "https://dl.photoprism.org/tensorflow/${name}.zip";
      stripRoot = false;
    };

  facenet = fetchModel {
    name = "facenet";
    sha256 = "sha256-aS5kkNhxOLSLTH/ipxg7NAa1w9X8iiG78jmloR1hpRo=";
  };

  nasnet = fetchModel {
    name = "nasnet";
    sha256 = "sha256-bF25jPmZLyeSWy/CGXZE/VE2UupEG2q9Jmr0+1rUYWE=";
  };

  nsfw = fetchModel {
    name = "nsfw";
    sha256 = "sha256-zy/HcmgaHOY7FfJUY6I/yjjsMPHR2Ote9ppwqemBlfg=";
  };

  libtensorflow = stdenv.mkDerivation rec {
    pname = "libtensorflow-photoprism";
    version = "1.15.2";

    srcs = [
      # Photoprism-packaged libtensorflow tarball (with pre-built libs for both arm64 and amd64)
      # We need this specific version because of https://github.com/photoprism/photoprism/issues/222
      (fetchurl {
        sha256 = {
          x86_64-linux = "sha256-bZAC3PJxqcjuGM4RcNtzYtkg3FD3SrO5beDsPoKenzc=";
          aarch64-linux = "sha256-qnj4vhSWgrk8SIjzIH1/4waMxMsxMUvqdYZPaSaUJRk=";
        }.${system} or (throw "Unsupported system");

        url =
          let
            systemName = {
              x86_64-linux = "amd64";
              aarch64-linux = "arm64";
            }.${system} or (throw "Unsupported system");
          in
          "https://dl.photoprism.app/tensorflow/${systemName}/libtensorflow-${systemName}-${version}.tar.gz";
      })
      # Upstream tensorflow tarball (with .h's photoprism's tarball is missing)
      (fetchurl {
        # Can't seem to find 1.15.2 tarball, but this works fine.
        url = "https://storage.googleapis.com/tensorflow/libtensorflow/libtensorflow-cpu-linux-x86_64-1.15.0.tar.gz";
        sha256 = "sha256-3sv9WnCeztNSP1XM+iOTN6h+GrPgAO/aNhfbeeEDTe0=";
      })
    ];

    sourceRoot = ".";

    unpackPhase = ''
      sources=($srcs)

      mkdir downstream upstream
      tar xf ''${sources[0]} --directory downstream
      tar xf ''${sources[1]} --directory upstream

      mv downstream/lib .
      mv upstream/{include,LICENSE,THIRD_PARTY_TF_C_LICENSES} .
      rm -r downstream upstream

      cd lib
      ln -sT libtensorflow.so{,.1}
      ln -sT libtensorflow_framework.so{,.1}
      cd ..
    '';

    # Patch library to use our libc, libstdc++ and others
    patchPhase =
      let
        rpath = makeLibraryPath [ stdenv.cc.libc stdenv.cc.cc.lib ];
      in
      ''
        chmod -R +w lib
        patchelf --set-rpath "${rpath}:$out/lib" lib/libtensorflow.so
        patchelf --set-rpath "${rpath}" lib/libtensorflow_framework.so
      '';

    buildPhase = ''
      # Write pkg-config file.
      mkdir lib/pkgconfig
      cat > lib/pkgconfig/tensorflow.pc << EOF
      Name: TensorFlow
      Version: ${version}
      Description: Library for computation using data flow graphs for scalable machine learning
      Requires:
      Libs: -L$out/lib -ltensorflow
      Cflags: -I$out/include/tensorflow
      EOF
    '';

    installPhase = ''
      mkdir -p $out
      cp -r LICENSE THIRD_PARTY_TF_C_LICENSES lib include $out
    '';
  };

  backend = buildGoModule rec {
    inherit pname version src;

    buildInputs = [
      coreutils
      libtensorflow
    ];

    postPatch = ''
      substituteInPlace internal/commands/passwd.go --replace '/bin/stty' "${coreutils}/bin/stty"
    '';

    vendorSha256 = "sha256-GaMV1SFDTCgZMZz0lYAKqqqX5zW+pU39vnwtlz2UDbQ=";

    subPackages = [ "cmd/photoprism" ];

    # https://github.com/mattn/go-sqlite3/issues/822
    CGO_CFLAGS = "-Wno-return-local-addr";

    # https://github.com/tensorflow/tensorflow/issues/43847
    CGO_LDFLAGS = "-fuse-ld=gold";
  };

  inherit (import ./node-composition.nix {
    inherit pkgs nodejs system;
  }) nodeDependencies;

  frontend = stdenv.mkDerivation {
    name = "photoprism-frontend";
    inherit src;
    buildInputs = [ nodejs ];

    buildPhase = ''
      runHook preBuild

      pushd frontend
      ln -s ${nodeDependencies}/lib/node_modules ./node_modules
      export PATH="${nodeDependencies}/bin:$PATH"
      NODE_ENV=production npm run build
      popd

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir $out
      cp -r assets $out/

      runHook postInstall
    '';
  };

in
stdenv.mkDerivation {
  inherit pname version;

  buildInputs = [
    darktable
    rawtherapee
    ffmpeg
    libheif
    exiftool
  ];

  phases = [ "installPhase" ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,assets}
    # install backend
    cp ${backend}/bin/photoprism $out/bin/photoprism
    # install frontend
    cp -r ${frontend}/assets $out/
    # install tensorflow models
    cp -r ${nasnet}/nasnet $out/assets
    cp -r ${nsfw}/nsfw $out/assets
    cp -r ${facenet}/facenet $out/assets

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://photoprism.app";
    description = "Personal Photo Management powered by Go and Google TensorFlow";
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    license = licenses.agpl3;
    maintainers = with maintainers; [ newam ];
  };
}
