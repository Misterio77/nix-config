{ lib, stdenv, fetchFromGitHub, makeWrapper
, findutils, gnugrep, procps, gawk, coreutils, openrgb, pastel, pulseaudio, playerctl, preferredplayer, sway}:

with lib;

stdenv.mkDerivation {
  name = "rgbdaemon";
  version = "0.1";
  src = fetchFromGitHub {
    owner = "Misterio77";
    repo = "rgbdaemon";
    rev = "068dcad606267a84f15c3decabaaac835feac2d1";
    sha256 = "sha256-Ek0MaUR0SO+zWukdXhKto/bWtN/Yd7CO/MoXzHj+E0A=";
  };

  nativeBuildInputs = [ makeWrapper ];

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    install -Dm 0755 rgbdaemon.sh $out/bin/rgbdaemon
    wrapProgram $out/bin/rgbdaemon --set PATH \
      "${makeBinPath [
        findutils
        gnugrep
        procps
        gawk
        coreutils
        openrgb
        pastel
        pulseaudio
        playerctl
        preferredplayer
        sway
      ]}"
  '';

  meta = {
    description = "A daemon that interacts with ckb-next and openrgb";
    homepage = "https://github.com/Misterio77/rgbdaemon";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = with maintainers; [ misterio77 ];
  };
}
