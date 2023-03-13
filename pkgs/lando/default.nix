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
  version = "3.11.0";

  src = fetchFromGitHub {
    owner = "lando";
    repo = "cli";
    rev = "v${version}";
    sha256 = "sha256-Bd75QTIzBEegBjkS0sZLda6kU3jTWNm05356arZI2yI=";
  };

  offlineCache = fetchYarnDeps {
    yarnLock = "${src}/yarn.lock";
    sha256 = "sha256-yZesQMkfviqbi9azor1WGzqYlhsHY4+/NVoawMBMWyo=";
  };

  nodejs = nodejs-16_x;

  postInstall = ''
    rm $out/libexec/@lando/cli/deps/@lando/cli/node_modules
    ln -sf $out/libexec/@lando/cli/node_modules $out/libexec/@lando/cli/deps/@lando/cli/node_modules
  '';

  meta = with lib; {
    description = "A development tool for all your projects that is fast, easy, powerful and liberating.";
    homepage = "https://lando.dev";
    license = licenses.gpl3;
    maintainers = with maintainers; [ misterio77 ];
    platforms = platforms.linux;
  };
}
