{ lib, hyprland, hyprlandPlugins, fetchFromGitHub }:
hyprlandPlugins.mkHyprlandPlugin hyprland {
  pluginName = "hyprbars";
  version = "0.1";
  src = fetchFromGitHub {
    owner = "hyprwm";
    repo = "hyprland-plugins";
    rev = "e9457e08ca3ff16dc5a815be62baf9e18b539197";
    hash = "sha256-qf6yev9OlJuQv557ApLQ/5V8pQj0YOO9tyh5j3It1mY=";
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
