{lib, pkg-config, hyprland, cmake, fetchFromGitHub, gnused}:
hyprland.stdenv.mkDerivation (final: {
  pname = "hyprbars";
  version = "0.53.3";

  src = "${fetchFromGitHub {
    owner = "hyprwm";
    repo = "hyprland-plugins";
    rev = "6acc0738f298f5efe40a99db2c12449112d65633";
    hash = "sha256-xmzpa+kFv1zDei3nT1sWZ/Q9TdMK/Rhx1I09VuO2F3E=";
  }}/hyprbars";
  buildInputs = [hyprland] ++ hyprland.buildInputs;
  nativeBuildInputs = [pkg-config cmake];

  postPatch = ''
    ${lib.getExe gnused} -i '/Initialized successfully/d' main.cpp
  '';

  meta = {
    inherit (hyprland.meta) platforms;
    license = lib.licenses.bsd3;
  };
})
