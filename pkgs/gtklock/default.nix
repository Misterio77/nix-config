{ lib, stdenv, fetchFromGitHub, pkg-config, gtk3, gtk-layer-shell, pam, scdoc }:
let
  pname = "gtklock";
in
stdenv.mkDerivation {
  inherit pname;
  version = "unstable-2022-07-17";

  src = fetchFromGitHub {
    owner = "jovanlanik";
    repo = pname;
    rev = "533799037bab53e47c16f3d7da97efbeb8f4cb0d";
    sha256 = "sha256-6catuQ4AP3TuAmI8+YSKGV0eOrm+E7rEFWBoC4oDx0s=";
  };

  makeFlags = [ "DESTDIR=$(out)" "PREFIX=" ];

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ gtk3 gtk-layer-shell pam scdoc ];

  meta = with lib; {
    homepage = "https://github.com/jovanlanik/gtklock";
    description = "GTK-based lockscreen for Wayland";
    license = licenses.gpl3Only;
    platforms = platforms.all;
    maintainers = [ maintainers.misterio77 ];
  };
}
