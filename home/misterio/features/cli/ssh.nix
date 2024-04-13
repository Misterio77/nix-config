{
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  hostnames = builtins.attrNames outputs.nixosConfigurations;
in {
  programs.ssh = {
    enable = true;
    matchBlocks = {
      trusted = {
        host = "m7.rs *.m7.rs *.ts.m7.rs" + (builtins.concatStringsSep " " hostnames);
        forwardAgent = true;
      };
    };
  };
  services.ssh-agent.enable = true;

  home.sessionVariables = lib.mkIf config.gtk.enable {
    SSH_ASKPASS_REQUIRE = "prefer";
    SSH_ASKPASS = "${pkgs.gnome.seahorse}/libexec/seahorse/ssh-askpass";
  };

  systemd.user.services.ssh-agent.Service.Environment = [
    "SSH_ASKPASS=${config.home.sessionVariables.SSH_ASKPASS or ""}"
  ];
  home.persistence = {
    "/persist/home/misterio".directories = [".ssh"];
  };
}
