{lib, pkg-config, hyprland, cmake, fetchFromGitHub, gnused}:
hyprland.stdenv.mkDerivation (final: {
  pname = "hyprbars";
  version = "0.52.1";

  src = "${fetchFromGitHub {
    owner = "hyprwm";
    repo = "hyprland-plugins";
    rev = "8c1212e96b81aa5f11fe21ca27defa2aad5b3cf3";
    hash = "sha256-Q5sI25sJRszoPxYv0dhJFip/Wq3wUppwJj8go+oTwu8=";
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
