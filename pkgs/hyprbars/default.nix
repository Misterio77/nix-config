{ lib, hyprland, hyprlandPlugins, fetchFromGitHub }:
hyprlandPlugins.mkHyprlandPlugin hyprland {
  pluginName = "hyprbars";
  version = "0.1";
  src = fetchFromGitHub {
    owner = "hyprwm";
    repo = "hyprland-plugins";
    rev = "c28d1011f4868c1a1ee80b10d9ee79900686df82";
    hash = "sha256-KrSLG2H3KGELxTFdiBhv8U6D53Q3UsJsQO+KgEabsNA=";
  };
  sourceRoot = "source/hyprbars";

  inherit (hyprland) nativeBuildInputs;

  meta = with lib; {
    homepage = "https://github.com/hyprwm/hyprland-plugins";
    description = "Hyprland window title plugin";
    license = licenses.bsd3;
    platforms = platforms.linux;
  };
}
