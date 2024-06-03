{ lib, hyprland, hyprlandPlugins, fetchFromGitHub }:
hyprlandPlugins.mkHyprlandPlugin hyprland {
  pluginName = "hyprbars";
  version = "0.1";
  src = fetchFromGitHub {
    owner = "hyprwm";
    repo = "hyprland-plugins";
    rev = "d716d1221348b5bef9d13161876caa91a3e33705";
    hash = "sha256-XP9v42PdSBkP/JlllfZR/0FDD1PMAVqw+LhOi79g0MA=";
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
