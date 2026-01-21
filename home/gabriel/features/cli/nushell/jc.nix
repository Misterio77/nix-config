{pkgs, ...}: {
  home.packages = [pkgs.jc];
  programs.nushell.extraConfig = /*nu*/ ''
    use ${pkgs.nu_scripts}/share/nu_scripts/modules/jc
  '';
}
