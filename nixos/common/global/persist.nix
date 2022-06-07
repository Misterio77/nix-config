{ persistence, inputs, lib, ... }:
let
  sshPath = if persistence then "/persist/etc/ssh" else "/etc/ssh";
in
{
  imports = [
    inputs.impermanence.nixosModules.impermanence
  ];

  environment.persistence = lib.mkIf persistence {
    "/persist" = {
      directories = [
        "/var/log"
        "/var/lib/systemd"
        "/var/lib/acme"
        "/etc/NetworkManager/system-connections"
      ];
    };
  };

  services.openssh.hostKeys = [
    {
      bits = 4096;
      path = "${sshPath}/ssh_host_rsa_key";
      type =
        "rsa";
    }
    {
      path = "${sshPath}/ssh_host_ed25519_key";
      type = "ed25519";
    }
  ];

  sops = {
    age.sshKeyPaths = [ "${sshPath}/ssh_host_ed25519_key" ];
  };

  # Allows accessing mountpoints when sudoing
  programs.fuse.userAllowOther = true;
}
