{
  _version = 28;
  chunk-loading = {
    autoconfig-send-distance = true;
    enable-frustum-priority = false;
    global-max-chunk-load-rate = -1.0;
    global-max-chunk-send-rate = -1.0;
    global-max-concurrent-loads = 500.0;
    max-concurrent-sends = 2;
    min-load-radius = 2;
    player-max-chunk-load-rate = -1.0;
    player-max-concurrent-loads = 20.0;
    target-player-chunk-send-rate = 100.0;
  };
  chunk-system = {
    gen-parallelism = "default";
    io-threads = -1;
    worker-threads = -1;
  };
  collisions = {
    enable-player-collisions = true;
    send-full-pos-for-hard-colliding-entities = true;
  };
  commands = {
    fix-target-selector-tag-completion = true;
    suggest-player-names-when-null-tab-completions = true;
    time-command-affects-all-worlds = false;
  };
  console = {
    enable-brigadier-completions = true;
    enable-brigadier-highlighting = true;
    has-all-permissions = false;
  };
  item-validation = {
    book = {
      author = 8192;
      page = 16384;
      title = 8192;
    };
    book-size = {
      page-max = 2560;
      total-multiplier = 0.98;
    };
    display-name = 8192;
    lore-line = 8192;
    resolve-selectors-in-books = false;
  };
  logging = {
    deobfuscate-stacktraces = true;
    log-player-ip-addresses = true;
    use-rgb-for-named-text-colors = true;
  };
  messages = {
    kick = {
      authentication-servers-down = "<lang:multiplayer.disconnect.authservers_down>";
      connection-throttle = "Connection throttled! Please wait before reconnecting.";
      flying-player = "<lang:multiplayer.disconnect.flying>";
      flying-vehicle = "<lang:multiplayer.disconnect.flying>";
    };
    no-permission = "<red>I'm sorry, but you do not have permission to perform this command.";
    use-display-name-in-quit-message = false;
  };
  misc = {
    chat-threads = {
      chat-executor-core-size = -1;
      chat-executor-max-size = -1;
    };
    fix-entity-position-desync = true;
    lag-compensate-block-breaking = true;
    load-permissions-yml-before-plugins = true;
    max-joins-per-tick = 5;
    region-file-cache-size = 256;
    strict-advancement-dimension-check = false;
    use-alternative-luck-formula = false;
    use-dimension-type-for-custom-spawners = false;
  };
  packet-limiter = {
    all-packets = {
      action = "KICK";
      interval = 7.0;
      max-packet-rate = 500.0;
    };
    kick-message = "<red><lang:disconnect.exceeded_packet_rate>";
    overrides = {
      ServerboundPlaceRecipePacket = {
        action = "DROP";
        interval = 4.0;
        max-packet-rate = 5.0;
      };
    };
  };
  player-auto-save = {
    max-per-tick = -1;
    rate = -1;
  };
  proxies = {
    bungee-cord = {
      online-mode = true;
    };
    proxy-protocol = false;
  };
  scoreboards = {
    save-empty-scoreboard-teams = false;
    track-plugin-scoreboards = false;
  };
  spam-limiter = {
    incoming-packet-threshold = 300;
    recipe-spam-increment = 1;
    recipe-spam-limit = 20;
    tab-spam-increment = 1;
    tab-spam-limit = 500;
  };
  timings = {
    enabled = true;
    hidden-config-entries = [ "database" "proxies.velocity.secret" ];
    history-interval = 300;
    history-length = 3600;
    server-name = "Unknown Server";
    server-name-privacy = false;
    url = "https://timings.aikar.co/";
    verbose = true;
  };
  unsupported-settings = {
    allow-grindstone-overstacking = false;
    allow-headless-pistons = false;
    allow-permanent-block-break-exploits = false;
    allow-piston-duplication = false;
    perform-username-validation = true;
  };
  watchdog = {
    early-warning-delay = 10000;
    early-warning-every = 5000;
  };
}
