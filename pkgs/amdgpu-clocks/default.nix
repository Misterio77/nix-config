{ lib, stdenv, fetchFromGitHub }:

with lib;

stdenv.mkDerivation {
  name = "amdgpu-clocks";
  version = "0.1";
  src = fetchFromGitHub {
    owner = "sibradzic";
    repo = "amdgpu-clocks";
    rev = "5a3bcd27bb7c2a421618e8bf290f25bfccb92301";
    sha256 = "sha256-UaZpAjuNQPCF7N14Zx8i2SbomskuB22k2Ql0qfnxX2E=";
  };

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    install -Dm 0755 amdgpu-clocks $out/bin/amdgpu-clocks
  '';

  meta = {
    description = "Simple script to control power states of amdgpu driven GPUs";
    homepage = "https://github.com/sibradzic/amdgpu-clocks";
    license = licenses.gpl2;
    platforms = platforms.linux;
    maintainers = with maintainers; [ misterio77 ];
  };
}
