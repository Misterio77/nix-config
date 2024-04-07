{
  config,
  inputs,
  pkgs,
  ...
}: {
  imports = [inputs.disconic.nixosModules.default];

  services.disconic = {
    enable = true;
    package = pkgs.inputs.disconic.default;
    user = "disconic";
    environmentFile = config.sops.secrets.disconic-secrets.path;
  };

  sops.secrets = {
    disconic-secrets = {
      owner = "disconic";
      group = "disconic";
      sopsFile = ../secrets.yaml;
    };
  };
}
