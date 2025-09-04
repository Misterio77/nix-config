{inputs, config, ...}: {
  system.hydraAutoUpgrade = {
    enable = true;
    dates = "*:0/10"; # Every 10 minutes
    instance = "https://hydra.m7.rs";
    project = "nix-config";
    jobset = "main";
    job = "hosts.${config.networking.hostName}";
    oldFlakeRef = "self";
  };
  # Disable timer if flake is dirty
  systemd.timers.nixos-upgrade.enable = inputs.self ? rev;
}
