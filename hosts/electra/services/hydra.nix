{ config, ... }:
let
  hydraUser = config.users.users.hydra.name;
  hydraGroup = config.users.users.hydra.group;

  # Make build machine file field
  field = x:
    if (x == null || x == [ ] || x == "") then "-"
    else if (builtins.isInt x) then (builtins.toString x)
    else if (builtins.isList x) then (builtins.concatStringsSep "," x)
    else x;
  mkBuildMachine =
    { uri ? null
    , systems ? null
    , sshKey ? null
    , maxJobs ? null
    , speedFactor ? null
    , supportedFeatures ? null
    , mandatoryFeatures ? null
    , publicHostKey ? null
    }: ''
      ${field uri} ${field systems} ${field sshKey} ${field maxJobs} ${field speedFactor} ${field supportedFeatures} ${field mandatoryFeatures} ${field publicHostKey}
    '';
  mkBuildMachinesFile = x: builtins.toFile "machines" (
    builtins.concatStringsSep "\n" (
      map (mkBuildMachine) x
    )
  );
in
{
  # https://github.com/NixOS/nix/issues/5039
  nix.extraOptions = ''
    allowed-uris = https:// http://
  '';
  services = {
    hydra = {
      enable = true;
      hydraURL = "https://hydra.m7.rs";
      notificationSender = "hydra@m7.rs";
      listenHost = "localhost";
      smtpHost = "localhost";
      useSubstitutes = true;
      extraConfig = /* xml */ ''
        Include ${config.sops.secrets.hydra-gh-auth.path}
        <githubstatus>
          jobs = .*
          useShortContext = true
        </githubstatus>
      '';
      buildMachinesFiles = [
        (mkBuildMachinesFile [
          {
            uri = "ssh://nix-ssh@atlas";
            systems = [ "x86_64-linux" "aarch64-linux" ];
            sshKey = config.sops.secrets.nix-ssh-key.path;
            maxJobs = 12;
            speedFactor = 150;
          }
          {
            uri = "ssh://nix-ssh@maia";
            systems = [ "x86_64-linux" "aarch64-linux" ];
            sshKey = config.sops.secrets.nix-ssh-key.path;
            maxJobs = 8;
            speedFactor = 100;
          }
          {
            uri = "localhost";
            systems = [ "x86_64-linux" "aarch64-linux" ];
            maxJobs = 2;
            speedFactor = 50;
          }
        ])
      ];
      extraEnv = { HYDRA_DISALLOW_UNFREE = "0"; };
    };
    nginx.virtualHosts = {
      "hydra.m7.rs" = {
        forceSSL = true;
        enableACME = true;
        locations = {
          "~* ^/shield/([^\\s]*)".return =
            "302 https://img.shields.io/endpoint?url=https://hydra.m7.rs/$1/shield";
          "/".proxyPass =
            "http://localhost:${toString config.services.hydra.port}";
        };
      };
    };
  };
  users.users = {
    hydra-queue-runner.extraGroups = [ hydraGroup ];
    hydra-www.extraGroups = [ hydraGroup ];
  };
  sops.secrets = {
    hydra-gh-auth = {
      sopsFile = ../secrets.yaml;
      owner = hydraUser;
      group = hydraGroup;
      mode = "0440";
    };
    nix-ssh-key = {
      sopsFile = ../secrets.yaml;
      owner = hydraUser;
      group = hydraGroup;
      mode = "0440";
    };
  };

  environment.persistence = {
    "/persist".directories = [ "/var/lib/hydra" ];
  };
}
