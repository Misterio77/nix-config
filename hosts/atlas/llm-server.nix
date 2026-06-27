{
  lib,
  outputs,
  pkgs,
  ...
}: let
  port = 18080;
  models = {
    # flash-attn + q8_0 KV cache halves the KV footprint to stay under 8GB VRAM.
    # Qwen3.6 35B-A3B (MoE, vision-capable - served text-only here). Q5_K_M
    # unsloth UD quant; ~16GB+ stays in RAM. ~16/48 layers on GPU as a start.
    # 64k of the model's native 256k ctx; full attention so KV grows linearly.
    # RAM holds the CPU-layer KV fine; drop ngl if the GPU-side KV won't fit.
    "qwen3.6-35b-a3b" = {
      hf = "unsloth/Qwen3.6-35B-A3B-GGUF:Q5_K_M";
      ctx-size = 65536;
      n-gpu-layers = 15;
      flash-attn = "on";
      cache-type-k = "q8_0";
      cache-type-v = "q8_0";
      threads = 8;
      parallel = 1;
      cont-batching = 1;
      sleep-idle-seconds = 300;
    };
    # Gemma-4-26B-A4B (MoE, 4B active, vision-capable - text-only here).
    # QAT q4_0: trained for q4 robustness, ~bf16 quality at only 13.5GB. Good
    # for chatty/creative work. Official Google GGUF, ungated. Light enough to
    # push ngl high - nudge up while watching VRAM. Sliding-window attention
    # bounds the KV cache, so its full native 256k ctx is cheap.
    gemma-4-26b-a4b = {
      hf = "google/gemma-4-26B-A4B-it-qat-q4_0-gguf:Q4_0";
      ctx-size = 262144;
      n-gpu-layers = 20;
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

  users.users.llama = {
    isSystemUser = true;
    group = "llama";
    home = "/var/lib/llama";
  };
  users.groups.llama = {};

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
      User = "llama";
      Group = "llama";
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
