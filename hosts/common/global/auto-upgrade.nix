{inputs, config, ...}: {
  system.hydraAutoUpgrade = {
    # Only enable if not dirty
    # As otherwise lastModified is innacurate
    enable = inputs.self ? rev;
    dates = "hourly";
    instance = "https://hydra.m7.rs";
    project = "nix-config";
    jobset = "main";
    job = "hosts.${config.networking.hostName}";
    lastModified = inputs.self.lastModified;
    oldFlakeRef = "self";
  };
}
