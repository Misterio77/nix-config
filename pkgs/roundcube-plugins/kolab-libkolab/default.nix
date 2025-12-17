{stdenv, fetchFromGitHub, ...}: stdenv.mkDerivation {
  pname = "kolab-libkolab";
  version = "3.6.1";

  src = fetchFromGitHub {
    owner = "kolab-roundcube-plugins-mirror";
    repo = "libkolab";
    rev = "3.6.1";
    hash = "sha256-yZGxT/4GQxvFb/UVn3qzdnR34y82DQhq6glzGRXAGRE=";
  };

  installPhase = ''
    mkdir -p $out/plugins
    cp -r $src $out/plugins/libkolab
  '';
}
