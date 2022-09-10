{ buildGoModule, fetchFromGitHub, lib }:
let
  pname = "clematis";
in
buildGoModule {
  inherit pname;
  version = "2022-02-08";

  src = fetchFromGitHub {
    owner = "Misterio77";
    repo = "${pname}";
    rev = "63715708a4a33cfe5593dae9a11ecc97d8f90e64";
    sha256 = "sha256-XgHxRChcyeoUibIFAleROUCPskHDzZSD1Kl7FUMVt7U=";
  };

  vendorSha256 = "sha256-YKu+7LFUoQwCH//URIswiaqa0rmnWZJvuSn/68G3TUA=";

  meta = with lib; {
    description = "Discord rich presence for MPRIS music players.";
    homepage = "https://github.com/TorchedSammy/Clematis";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
