{lib, pkg-config, hyprland, cmake, fetchFromGitHub, gnused}:
hyprland.stdenv.mkDerivation (final: {
  pname = "hyprbars";
  version = "0.51.0";

  src = "${fetchFromGitHub {
    owner = "hyprwm";
    repo = "hyprland-plugins";
    rev = "a5a6f93d72d5fb37e78b98c756cfd8b340e71a19";
    hash = "sha256-6jAtMjnWq8kty/dpPbIKxIupUG+WAE2AKMIKhxdLYNo=";
  }}/hyprbars";
  buildInputs = [hyprland] ++ hyprland.buildInputs;
  nativeBuildInputs = [pkg-config cmake];

  postPatch = ''
    ${lib.getExe gnused} -i '/Initialized successfully/d' main.cpp
  '';

  meta = {
    inherit (hyprland.meta) platform;
    license = lib.licenses.bsd3;
  };
})
