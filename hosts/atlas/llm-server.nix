{
  lib,
  outputs,
  pkgs,
  ...
}: let
  port = 18080;
  models = {
    # Section name is the canonical hf-repo id so the preset owns it; otherwise
    # the router auto-registers an untuned twin. Short alias kept for convenience.
    # flash-attn + q8_0 KV cache halves the KV footprint to stay under 8GB VRAM.
    "Qwen/Qwen3-8B-GGUF:Q5_K_M" = {
      hf = "Qwen/Qwen3-8B-GGUF:Q5_K_M";
      alias = "Qwen/Qwen3-8B-GGUF:Q5_K_M,qwen3-8b";
      ctx-size = 32768;
      n-gpu-layers = 999;
      flash-attn = "on";
      cache-type-k = "q8_0";
      cache-type-v = "q8_0";
      threads = 8;
      parallel = 1;
      cont-batching = 1;
      sleep-idle-seconds = 300;
    };
    # MoE 30B-A3B mostly CPU-resident, but only 3B active params keep it fast.
    # Q5_K_M (not Q4): MoEs are more quant-sensitive than dense models and we
    # have the RAM to spare. ~16/48 layers on GPU as a starting point.
    "Qwen/Qwen3-30B-A3B-GGUF:Q5_K_M" = {
      hf = "Qwen/Qwen3-30B-A3B-GGUF:Q5_K_M";
      alias = "Qwen/Qwen3-30B-A3B-GGUF:Q5_K_M,qwen3-30b-a3b";
      ctx-size = 32768;
      n-gpu-layers = 16;
      flash-attn = "on";
      cache-type-k = "q8_0";
      cache-type-v = "q8_0";
      threads = 8;
      parallel = 1;
      cont-batching = 1;
      sleep-idle-seconds = 300;
    };
  };
in {
  services.nginx.virtualHosts."llm.m7.rs" = {
    locations."/" = {
      proxyPass = "http://localhost:${toString port}";
      extraConfig = ''
        allow 127.0.0.1;
        allow ::1;
        allow ${outputs.nixosConfigurations.alcyone.config.services.headscale.settings.prefixes.v4};
        allow ${outputs.nixosConfigurations.alcyone.config.services.headscale.settings.prefixes.v6};
        deny all;
      '';
    };
  };

  systemd.services.llama-cpp-router = {
    description = "Local llama.cpp router API";
    after = ["network-online.target"];
    wants = ["network-online.target"];
    wantedBy = ["multi-user.target"];
    environment = {
      XDG_CACHE_HOME = "/var/lib/llama";
      XDG_DATA_HOME = "/var/lib/llama";
    };
    path = [pkgs.llama-cpp-vulkan];
    script = lib.concatStringsSep " " [
      "llama-server"
      # No --models-dir: all models come from --models-preset below.
      # The preset parser reads INI values verbatim (no quote stripping), so use
      # plain INI, not TOML - quoted strings would keep their literal quotes.
      "--models-preset ${(pkgs.formats.ini {}).generate "llama-cpp-models.ini" models}"
      "--models-max 1"
      "--host 127.0.0.1"
      "--port ${toString port}"
    ];
    serviceConfig = {
      DynamicUser = true;
      StateDirectory = "llama";
      RuntimeDirectory = "llama";
      SupplementaryGroups = ["render" "video"];
      Restart = "on-failure";
      RestartSec = 2;
      # llama-server can dawdle on shutdown; SIGKILL it after 15s.
      TimeoutStopSec = 15;
    };
  };
}
