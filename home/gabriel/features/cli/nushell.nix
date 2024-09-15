{
  programs.carapace = {
    enable = true;
    enableNushellIntegration = true;
  };
  programs.nushell = {
    enable = true;
    configFile.text = /* nu */ ''
      $env.config.edit_mode = vi
    '';
  };
}
