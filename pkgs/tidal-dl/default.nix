{ lib
, buildPythonPackage
, buildPythonApplication
, fetchPypi
, mutagen
, requests
, colorama
, prettytable
, pycrypto
, pydub
}:
let
  aigpy = buildPythonPackage rec {
    pname = "aigpy";
    version = "2022.7.8.1";

    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-1kQced6YdC/wvegqFVhZfej4+4aemGXvKysKjejP13w=";
    };

    propagatedBuildInputs = [ mutagen requests colorama prettytable pycrypto pydub ];
  };
in
buildPythonApplication rec {
  pname = "tidal-dl";
  version = "2022.10.31.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-b2AAsiI3n2/v6HC37fMI/d8UcxZxsWM+fnWvdajHrOg=";
  };

  propagatedBuildInputs = [ aigpy ];

  meta = with lib; {
    homepage = "https://github.com/yaronzz/Tidal-Media-Downloader";
    description = "An application that lets you download videos and tracks from Tidal";
    license = licenses.asl20;
    maintainers = with maintainers; [ misterio77 ];
    platforms = platforms.all;
  };
}
