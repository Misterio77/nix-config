{ pkgs, lib, config, outputs, ... }:
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

  release-host-branch = pkgs.writeShellApplication {
    name = "release-host-branch";
    runtimeInputs = with pkgs; [ jq git ];
    text = ''
      job="$(jq -r '.job' < "$HYDRA_JSON")"
      outpath="$(jq -r '.outputs[] | select(.name == "out") | .path' < "$HYDRA_JSON")"
      echo "Running for $job, built $outpath"

      if [[ "$job" != "hosts."* ]]; then
          echo "Not a NixOS Host job, skipping."
          exit 0
      fi

      host="''${job##*.}"
      commit="$(jq -r '.flakes[] | select(.from.id == "self") | .to.rev' "''${outpath}/etc/nix/registry.json")"
      echo "System is $host at $commit"

      # Start ssh-agent if nescessary
      ssh-add || eval "$(ssh-agent)"
      ssh-add ${config.sops.secrets.nix-ssh-key.path}
      export GIT_SSH_COMMAND="ssh -A" # Forward agent

      repo="/tmp/hydra/nix-config"

      # Check if repo already exists
      if git -C "$repo" rev-parse --git-dir &> /dev/null; then
        git -C "$repo" fetch origin
      else
        mkdir -p "$repo"
        git clone --bare git@m7.rs:nix-config "$repo"
      fi

      git -C "$repo" branch -f "release-$host" "$commit"
      git -C "$repo" push -f origin "release-$host" -o "release-$host"
    '';
  };
in
{
  # https://github.com/NixOS/nix/issues/5039
  nix.extraOptions = ''
    allowed-uris = https:// http://
  '';
  # https://github.com/NixOS/nix/issues/4178#issuecomment-738886808
  systemd.services.hydra-evaluator.environment.GC_DONT_GC = "true";
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
        max_unsupported_time = 30
        <githubstatus>
          jobs = .*
          useShortContext = true
        </githubstatus>
        <runcommand>
          job = nix-config:main:*
          command = ${release-host-branch}/bin/release-host-branch &> /tmp/hydra-release-log
        </runcommand>
      '';
      buildMachinesFiles = [
        (mkBuildMachinesFile [
          {
            uri = "ssh://nix-ssh@atlas";
            systems = [ "x86_64-linux" "i686-linux" ];
            sshKey = config.sops.secrets.nix-ssh-key.path;
            maxJobs = 12;
            speedFactor = 150;
          }
          {
            uri = "ssh://nix-ssh@maia";
            systems = [ "x86_64-linux" "i686-linux" ];
            sshKey = config.sops.secrets.nix-ssh-key.path;
            maxJobs = 8;
            speedFactor = 100;
          }
          {
            uri = "localhost";
            systems = [ "aarch64-linux" "x86_64-linux" "i686-linux" ];
            maxJobs = 4;
            speedFactor = 70;
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
