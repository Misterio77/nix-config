{ pkgs
, stdenv
, fetchFromGitHub
, hyprland
, hyprland-protocols
, wlroots-hyprland
, cairo
, libdrm
, libglvnd
, libinput
, libxkbcommon
, pixman
, wayland
, xorg
}:
stdenv.mkDerivation {
  pname = "hyprbars";
  version = "unstable-2023-03-17";
  src = fetchFromGitHub {
    owner = "hyprwm";
    repo = "hyprland-plugins";
    rev = "3b44ce9725286064e62d4b0e424f270058375478";
    sha256 = "sha256-4htvOSa1mYKc9u8IUd0b1kpCHPiJIZGSxEGuWZ+REmw=";
  };

  buildInputs = [
    (pkgs.callPackage ../headers { inherit hyprland hyprland-protocols; })
    cairo
    libglvnd
    libinput
    libxkbcommon
    wayland
    wlroots-hyprland
    xorg.libxcb
    xorg.xcbutilwm
  ];

  sourceRoot = "source/hyprbars";
  NIX_CFLAGS_COMPILE = [
    "-I ${libdrm.dev}/include/libdrm"
    "-I ${pixman}/include/pixman-1"
  ];

  installPhase = ''
    mkdir -p $out/share
    cp hyprbars.so $out/share/
  '';

  # It's building, but I get a "error in loading plugin"
  # TODO
  meta.broken = true;
}
