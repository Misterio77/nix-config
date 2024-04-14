{
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (config.networking) hostName;
  hosts = outputs.nixosConfigurations;
  pubKey = host: ../../${host}/ssh_host_ed25519_key.pub;
  gitHost = hosts."alcyone".config.networking.hostName;

  # Sops needs acess to the keys before the persist dirs are even mounted; so
  # just persisting the keys won't work, we must point at /persist
  hasOptinPersistence = config.environment.persistence ? "/persist";
in {
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

    hostKeys = [
      {
        path = "${lib.optionalString hasOptinPersistence "/persist"}/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };

  programs.ssh = {
    # Each hosts public key
    knownHosts =
      builtins.mapAttrs (name: _: {
        publicKeyFile = pubKey name;
        extraHostNames =
          (lib.optional (name == hostName) "localhost")
          # Alias for localhost if it's the same host
          ++ (lib.optionals (name == gitHost) [
            "m7.rs"
            "git.m7.rs"
          ]); # Alias for m7.rs and git.m7.rs if it's the git host
      })
      hosts;
  };

  # Passwordless sudo when SSH'ing with keys
  security.pam.services.sudo = {config, ...}: {
    rules.auth.rssh = {
      order = config.rules.auth.ssh_agent_auth.order - 1;
      control = "sufficient";
      modulePath = "${pkgs.pam_rssh}/lib/libpam_rssh.so";
      settings.authorized_keys_command =
        pkgs.writeShellScript "get-authorized-keys"
        ''
          cat "/etc/ssh/authorized_keys.d/$1"
        '';
    };
  };
  # Keep SSH_AUTH_SOCK when sudo'ing
  security.sudo.extraConfig = ''
    Defaults env_keep+=SSH_AUTH_SOCK
  '';
}
