{pkgs, ...}: {
  home.packages = [pkgs.inputs.hytale.default];
  home.persistence."/persist".directories = [".local/share/Hytale"];
}
