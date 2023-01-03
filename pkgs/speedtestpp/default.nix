{ stdenv, lib, fetchFromGitHub, cmake, curl, openssl, libxml2 }:
stdenv.mkDerivation rec {
  pname = "speedtestpp";
  version = "2021-08-29";
  src = fetchFromGitHub {
    owner = "taganaka";
    repo = "speedtest";
    rev = "0f63cfbf7ce8d64ea803bf143b957eae76323405";
    sha256 = "sha256-rGY0kK2OCZl+229/JERf2ghBSdvAedhVuL4SrVzYFmU=";
  };
  nativeBuildInputs = [ cmake curl openssl libxml2 ];
  postInstall = ''
    ln -s $out/bin/SpeedTest $out/bin/speedtestpp
  '';

  meta = with lib; {
    description = "Unofficial speedtest.net cli using raw TCP for better accuracy";
    homepage = "https://github.com/taganaka/SpeedTest";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
