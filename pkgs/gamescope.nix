{ stdenv, fetchFromGitHub, pkgs }:

stdenv.mkDerivation {
  pname = "gamescope";
  version = "git";

  src = fetchFromGitHub {
    owner = "Plagman";
    repo = "gamescope";
    rev = "802d86c4bc65d96414abd686b9e8ed223ba2f6a7";
    sha256 = "sha256-EGWGQTPSS3AYe5NT1QQJRod7lFQhFyB7NT0FSYMyejU=";
  };

  nativeBuildInputs = with pkgs; [ meson ninja pkgconfig cmake vulkan-headers glslang wayland-protocols ];
  buildInputs = with pkgs; [
    SDL2
    libcap
    libdrm
    libinput
    libliftoff
    libxkbcommon
    pixman
    udev
    vulkan-loader
    wayland
    wlroots
    x11
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXi
    xorg.libXrender
    xorg.libXres
    xorg.libXtst
    xorg.libXxf86vm
  ];
}

