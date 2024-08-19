{ lib, hyprland, hyprlandPlugins, fetchFromGitHub }:
hyprlandPlugins.mkHyprlandPlugin hyprland {
  pluginName = "hyprbars";
  version = "0.1";
  src = fetchFromGitHub {
    owner = "hyprwm";
    repo = "hyprland-plugins";
    rev = "b73d7b901d8cb1172dd25c7b7159f0242c625a77";
    hash = "sha256-dPcWAeRJoG5CyWC32X3XX+Og0v/k1/S1N0T5dQWT32k=";
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
