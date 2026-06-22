{lib, pkg-config, hyprland, cmake, fetchFromGitHub, gnused}:
hyprland.stdenv.mkDerivation (final: {
  pname = "hyprbars";
  version = "0.53.3";

  src = "${fetchFromGitHub {
    owner = "hyprwm";
    repo = "hyprland-plugins";
    rev = "3aa21f2e0ca72412f1b434c3126f8f1fec3c716c";
    hash = "sha256-VTRC7MN4HReathEqTEAGtTb6X6fjFXLhK4/+jZHTl1Q=";
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
