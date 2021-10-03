{ lib, stdenv, fetchFromGitHub, makeWrapper
, pass, jq, wofi, libnotify, qutebrowser, sway, wl-clipboard, findutils, gnused
}:

with lib;

stdenv.mkDerivation {
  name = "pass-wofi";
  version = "1.0";
  src = fetchFromGitHub {
    owner = "Misterio77";
    repo = "pass-wofi";
    rev = "269918667672ac11cff850b50aeaf53315e97e38";
    sha256 = "sha256-IFGuL2UQHJ46Be5ZCXn3zKoYpxr62X+eYyNVYLKRf38=";
  };

  nativeBuildInputs = [ makeWrapper ];

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    install -Dm 0755 pass-wofi.sh $out/bin/pass-wofi
    wrapProgram $out/bin/pass-wofi --set PATH \
      "${makeBinPath [
        pass
        jq
        wofi
        libnotify
        qutebrowser
        sway
        wl-clipboard
        findutils
        gnused
      ]}"
  '';

  meta = {
    description = "A wofi graphical menu for pass";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = with maintainers; [ misterio77 ];
  };
}

