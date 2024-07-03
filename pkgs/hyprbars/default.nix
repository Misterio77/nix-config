{ lib, hyprland, hyprlandPlugins, fetchFromGitHub }:
hyprlandPlugins.mkHyprlandPlugin hyprland {
  pluginName = "hyprbars";
  version = "0.1";
  src = fetchFromGitHub {
    owner = "hyprwm";
    repo = "hyprland-plugins";
    rev = "135de7b88649dbe5fea8c997447bdc9d6f15ad86";
    hash = "sha256-VPXoV9osFbbjCmOnwN+8/7P1508SCp7CO7Y06AayQqs=";
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
