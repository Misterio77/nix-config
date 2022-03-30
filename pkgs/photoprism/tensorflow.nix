{ lib
, stdenv
, fetchFromGitHub
, fetchurl
, system
}:

with lib;
let
  rpath = makeLibraryPath ([ stdenv.cc.libc stdenv.cc.cc.lib ]);

  systemName =
    if system == "x86_64-linux" then "amd64"
    else if system == "aarch64-linux" then "arm64"
    else throw "Unsupported system";


in
stdenv.mkDerivation rec {
  pname = "libtensorflow";
  version = "1.15.2";

  srcs = [
    # Downstream photoprism libtensorflow tarball (with pre-built libs for both arm64 and amd64)
    (fetchurl {
      url = "https://dl.photoprism.app/tensorflow/${systemName}/libtensorflow-${systemName}-${version}.tar.gz";
      sha256 =
        if system == "x86_64-linux" then "sha256-bZAC3PJxqcjuGM4RcNtzYtkg3FD3SrO5beDsPoKenzc="
        else if system == "aarch64-linux" then lib.fakeSha256
        else throw "Unsupported system";
    })
    # Upstream tensorflow tarball (with includes we'll need)
    (fetchurl {
      url = "https://storage.googleapis.com/tensorflow/libtensorflow/libtensorflow-cpu-linux-x86_64-1.15.0.tar.gz";
      sha256 = "sha256-3sv9WnCeztNSP1XM+iOTN6h+GrPgAO/aNhfbeeEDTe0=";
    })
  ];

  sourceRoot = ".";

  # Pierce both sources together
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
  patchPhase = ''
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

  meta = {
    description = "C API for TensorFlow (photoprism version)";
    homepage = "https://www.tensorflow.org/install/lang_c";
    license = licenses.asl20;
    platforms = [ "x86_64-linux" "aarch64-linux" ];
  };
}
