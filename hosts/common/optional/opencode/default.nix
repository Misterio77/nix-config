{config, lib, pkgs, ...}: {
  services.opencode = {
    enable = true;
    hostname = "0.0.0.0";
    settings = {
      autoupdate = false;
      model = "deepseek/deepseek-v4-flash";
      provider.deepseek.options.apiKey = "{file:${config.sops.secrets.deepseek-apikey.path}}";
      provider.openai.options.apiKey = "{file:${config.sops.secrets.openai-free-apikey.path}}";
      instructions = [config.sops.secrets.gabs-info.path];
      shell = lib.getExe pkgs.bash;
    };
    context = ./context.md;
    agents = {
      image-analyzer = ./agents/image-analyzer.md;
      pdf-reader = ./agents/pdf-reader.md;
      whisper-transcriber = ./agents/whisper-transcriber.md;
    };
    skills = {
      jujutsu = ./skills/jujutsu;
      gabs-tools = ./skills/gabs-tools;
      edit-skills = ./skills/edit-skills;
      nix-shell = ./skills/nix-shell;
      screenshot = ./skills/screenshot;
      firefly = ./skills/firefly;
      lumis = ./skills/lumis;
      browser = ./skills/browser;
    };
    extraFiles = {
      "skills/firefly/resources/private.md" = config.sops.secrets.skill-firefly-private.path;
      "skills/lumis/resources/private.md" = config.sops.secrets.skill-lumis-private.path;
    };
  };

  sops.secrets = {
    deepseek-apikey = {
      sopsFile = ../../secrets.yaml;
      owner = "opencode";
    };
    openai-free-apikey = {
      sopsFile = ../../secrets.yaml;
      owner = "opencode";
    };
    gabs-info = {
      sopsFile = ../../../../home/gabriel/features/opencode/private.yaml;
      owner = "opencode";
    };
    skill-lumis-private = {
      sopsFile = ../../../../home/gabriel/features/opencode/private.yaml;
      owner = "opencode";
    };
    skill-firefly-private = {
      sopsFile = ../../../../home/gabriel/features/opencode/private.yaml;
      owner = "opencode";
    };
    firefly-pat = {
      sopsFile = ../../secrets.yaml;
      owner = "opencode";
    };
    pluggy-secret = {
      sopsFile = ../../secrets.yaml;
      owner = "opencode";
    };
  };

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [
    config.services.opencode.port
  ];
}
