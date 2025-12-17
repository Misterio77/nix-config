{stdenv, fetchFromGitHub, ...}: stdenv.mkDerivation {
  pname = "kolab-calendar";
  version = "3.6.1";

  src = fetchFromGitHub {
    owner = "kolab-roundcube-plugins-mirror";
    repo = "calendar";
    rev = "3.6.1";
    hash = "sha256-arXPB/ZnV+8JN8XWC/yQA2jqKsP1TS2sVopti6TFpNA=";
  };

  installPhase = ''
    mkdir -p $out/plugins
    cp -r $src $out/plugins/calendar
  '';
}
