{ inputs, persistence, ... }:
let
  sshPath = if persistence then "/persist/etc/ssh" else "/etc/ssh";
in
{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  sops = {
    age.sshKeyPaths = [ "${sshPath}/ssh_host_ed25519_key" ];
  };
}
