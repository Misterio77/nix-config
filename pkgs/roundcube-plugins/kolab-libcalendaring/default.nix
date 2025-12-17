{stdenv, fetchFromGitHub, ...}: stdenv.mkDerivation {
  pname = "kolab-libcalendaring";
  version = "3.6.1";

  src = fetchFromGitHub {
    owner = "kolab-roundcube-plugins-mirror";
    repo = "libcalendaring";
    rev = "3.6.1";
    hash = "sha256-DEHrVQngTabsn9jTMtlFNQEnkZ/h1kcwxYNNqX1c+/o=";
  };

  installPhase = ''
    mkdir -p $out/plugins
    cp -r $src $out/plugins/libcalendaring
  '';
}
