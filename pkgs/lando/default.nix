{ lib
, stdenv
, fetchFromGitHub
, buildNpmPackage
, makeWrapper
, nodejs-16_x
, docker-compose_1
, docker
}:
let
  nodejs = nodejs-16_x;
  docker-compose = docker-compose_1;
in
buildNpmPackage.override { inherit nodejs; } rec {
  pname = "lando";
  version = "3.14.0";

  src = fetchFromGitHub {
    owner = "lando";
    repo = "cli";
    rev = "v${version}";
    sha256 = "sha256-BFqCmkAnIxeVgzeMvTXFS/mgU1z1KOe74px03qnOvhM=";
  };

  npmDepsHash = "sha256-G54gtJ3wClcHrTqMDQbnaDZ2yr8D3Hv8q3Bg1UeC0Tk=";

  makeCacheWritable = true;
  npmFlags = [ "--legacy-peer-deps" ];
  dontNpmBuild = true;

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  meta = with lib; {
    description = "A development tool for all your projects that is fast, easy, powerful and liberating.";
    homepage = "https://lando.dev";
    license = licenses.gpl3;
    maintainers = with maintainers; [ misterio77 ];
    platforms = platforms.linux;
    broken = true; # Not working 100%
  };
}
