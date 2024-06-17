{pkgs, ...}: {
  home = {
    packages = with pkgs; [pfetch-rs];
    sessionVariables.PF_INFO = "ascii title os kernel uptime shell de palette";
  };
}
