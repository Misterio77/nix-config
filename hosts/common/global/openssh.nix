{ persistence, ... }:
let
  sshPath = if persistence then "/persist/etc/ssh" else "/etc/ssh";
in
{
  services.openssh = {
    enable = true;
    # Harden
    passwordAuthentication = false;
    permitRootLogin = "no";
    # Automatically remove stale sockets
    extraConfig = ''
      StreamLocalBindUnlink yes
    '';
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
}
