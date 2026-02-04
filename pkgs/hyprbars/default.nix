{lib, pkg-config, hyprland, cmake, fetchFromGitHub, gnused}:
hyprland.stdenv.mkDerivation (final: {
  pname = "hyprbars";
  version = "0.53.3";

  src = "${fetchFromGitHub {
    owner = "hyprwm";
    repo = "hyprland-plugins";
    rev = "64b7c2dff7e5e1fcb4cb7e5db078947744070e1a";
    hash = "sha256-1WYjD66gyjj7PVOe7xbho6030FdrIUjh/XpAtp5+ASo=";
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
