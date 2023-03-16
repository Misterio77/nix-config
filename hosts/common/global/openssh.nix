{ outputs, lib, config, ... }:

let
  inherit (config.networking) hostName;
  hosts = outputs.nixosConfigurations;
  prefix = "/persist";
  pubKey = host: ../../${host}/ssh_host_ed25519_key.pub;
  gitHost = hosts."alcyone".config.networking.hostName;
in
{
  services.openssh = {
    enable = true;
    settings = {
      # Harden
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      # Automatically remove stale sockets
      StreamLocalBindUnlink = "yes";
      # Allow forwarding ports to everywhere
      GatewayPorts = "clientspecified";
    };

    hostKeys = [{
      path = "${prefix}/etc/ssh/ssh_host_ed25519_key";
      type = "ed25519";
    }];
  };

  programs.ssh = {
    # Each hosts public key
    knownHosts = builtins.mapAttrs
      (name: _: {
        publicKeyFile = pubKey name;
        extraHostNames =
          (lib.optional (name == hostName) "localhost") ++ # Alias for localhost if it's the same host
          (lib.optionals (name == gitHost) [ "m7.rs" "git.m7.rs" ]); # Alias for m7.rs and git.m7.rs if it's the git host
      })
      hosts;
  };

  # Passwordless sudo when SSH'ing with keys
  security.pam.enableSSHAgentAuth = true;
}
