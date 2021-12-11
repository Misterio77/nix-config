{ lib, stdenv, fetchurl, autoPatchelfHook, wrapQtAppsHook, qtbase, curl
, portaudio }:

stdenv.mkDerivation {
  name = "soundwire";
  version = "3.0.0";

  src = fetchurl {
    url = "http://georgielabs.altervista.org/SoundWire_Server_linux64.tar.gz";
    sha256 = "sha256-1g8qXAdQy4m8Mw0irGERYyeIfFOoeqweDcoj7mNGg80=";
  };

  nativeBuildInputs = [ wrapQtAppsHook autoPatchelfHook ];

  buildInputs = [ portaudio curl qtbase ];

  sourceRoot = ".";

  installPhase = ''
    cd SoundWireServer
    install -Dm755 SoundWireServer $out/bin/SoundWireServer
    install -Dm644 SoundWire-Server.desktop $out/share/applications/soundwire.desktop
  '';

  meta = { platforms = lib.platforms.linux; };
}
