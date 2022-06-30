{ lib
, stdenv
, fetchFromGitHub
, makeWrapper
, pass
, jq
, wofi
, libnotify
, wl-clipboard
, findutils
, gnused
, coreutils
}:

with lib;

stdenv.mkDerivation {
  name = "pass-wofi";
  version = "1.0";
  src = fetchFromGitHub {
    owner = "Misterio77";
    repo = "pass-wofi";
    rev = "3233c2814f01e7162bf27be6803b74997fd10fd7";
    sha256 = "sha256-9PN1NPMKvnYtMOWcZVTrFw4bxWfEH0NeHtFO6hPTrZk=";
  };

  nativeBuildInputs = [ makeWrapper ];

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    install -Dm 0755 pass-wofi.sh $out/bin/pass-wofi
    wrapProgram $out/bin/pass-wofi --set PATH \
      "${
        makeBinPath [
          pass
          jq
          wofi
          libnotify
          wl-clipboard
          findutils
          gnused
          coreutils
        ]
      }"
  '';

  meta = {
    description = "A wofi graphical menu for pass";
    homepage = "https://github.com/Misterio77/pass-wofi";
    license = licenses.mit;
    platforms = platforms.all;
  };
}

