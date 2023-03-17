{ stdenv
, hyprland
, hyprland-protocols
, meson
, ninja
, pkg-config
, jq
, git
, wayland-protocols
, wayland-scanner
, wayland
}:

stdenv.mkDerivation {
  name = "hyprland-protocol-headers";
  version = hyprland.version;

  src = hyprland.src;

  sourceRoot = "source/protocols";

  buildInputs = [ git hyprland-protocols wayland-protocols wayland-scanner wayland ];
  nativeBuildInputs = [ meson ninja pkg-config jq ];

  patchPhase = ''
    sed -i "1s/^/project('hyprland-protocols', 'cpp', 'c')\n/" meson.build
  '';

  installPhase = ''
    mkdir -p $out/include
    cp -r $src/src *.h $out/include/
  '';
}
