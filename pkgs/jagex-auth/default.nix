# Note: vibecoded (pi running gpt 5.5)
{
  lib,
  makeWrapper,
  python3,
  stdenvNoCC,
}: let
  python = python3.withPackages (ps: [ps.requests]);
in
  stdenvNoCC.mkDerivation {
    pname = "jagex-auth";
    version = "0-unstable";

    src = ./jagex-auth.py;
    dontUnpack = true;

    nativeBuildInputs = [makeWrapper];

    installPhase = ''
      runHook preInstall

      install -Dm644 $src $out/share/jagex-auth/jagex-auth.py
      makeWrapper ${lib.getExe python} $out/bin/jagex-auth \
        --add-flags $out/share/jagex-auth/jagex-auth.py \

      runHook postInstall
    '';

    meta = {
      description = "Small CLI for Jagex launcher OAuth tokens";
      mainProgram = "jagex-auth";
      license = lib.licenses.mit;
      platforms = lib.platforms.linux;
    };
  }
