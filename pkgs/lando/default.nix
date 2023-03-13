{ lib
, stdenv
, fetchFromGitHub
, mkYarnPackage
, fetchYarnDeps
, makeWrapper
, nodejs-16_x
, docker-compose_1
, docker
}:

mkYarnPackage rec {
  pname = "lando";
  version = "3.14.0";

  src = fetchFromGitHub {
    owner = "lando";
    repo = "cli";
    rev = "v${version}";
    sha256 = "sha256-BFqCmkAnIxeVgzeMvTXFS/mgU1z1KOe74px03qnOvhM=";
  };

  packageJSON = "${src}/package.json";
  yarnLock = "${src}/yarn.lock";
  offlineCache = fetchYarnDeps {
    inherit yarnLock;
    sha256 = "sha256-/I0ipli5u897LsG78PviztaidZjkGpZDlL+v/sVlCtk=";
  };

  nodejs = nodejs-16_x;
  dontStrip = true;
  nativeBuildInputs = [ makeWrapper ];

  postInstall =
    let
      pname = (lib.importJSON packageJSON).name;
    in
    ''
      rm $out/libexec/${pname}/deps/${pname}/node_modules
      ln -sf $out/libexec/${pname}/node_modules $out/libexec/${pname}/deps/${pname}/node_modules
    '';

  postFixup = ''
    wrapProgram $out/bin/lando --set PATH \
      "${lib.makeBinPath [
        docker
        docker-compose_1
      ]}"
  '';

  meta = with lib; {
    description = "A development tool for all your projects that is fast, easy, powerful and liberating.";
    homepage = "https://lando.dev";
    license = licenses.gpl3;
    maintainers = with maintainers; [ misterio77 ];
    platforms = platforms.linux;
  };
}
