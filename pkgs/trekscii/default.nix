{ stdenv, fetchFromGitHub }: stdenv.mkDerivation rec {
  pname = "trekscii";
  version = "unstable-2022-06-27";

  src = fetchFromGitHub {
    owner = "k-vernooy";
    repo = pname;
    rev = "8b51971c4c62f49f886d59f2c8445ce8734b00e8";
    hash = "sha256-Mn3wasplwXsDCBEpHLqdh0G+SqYIirj7lKvM3VehPH0=";
  };

  # Sane default values and crash avoidance (https://github.com/k-vernooy/trekscii/pull/1)
  patches = [ ./trekscii.patch ];

  installPhase = ''
    install -Dm 0755 bin/trekscii $out/bin/trekscii
  '';
}
