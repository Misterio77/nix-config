{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mapAttrs' replaceStrings nameValuePair;
in {
  services.minecraft-servers.servers.proxy = {
    extraReload = ''
      echo 'librelogin reload configuration' > /run/minecraft/proxy.stdin
      echo 'librelogin reload messages' > /run/minecraft/proxy.stdin
    '';
    symlinks."plugins/LibreLogin.jar" = pkgs.fetchurl rec {
      pname = "LibreLogin";
      version = "0.23.0";
      url = "https://github.com/kyngs/${pname}/releases/download/${version}/${pname}.jar";
      hash = "sha256-KpdBl1SN0Mm79jYuN8GsJudZga73duDHkiHDqSl7JKw=";
    };
    files = {
      "plugins/librelogin/config.conf".format = pkgs.formats.json {};
      "plugins/librelogin/config.conf".value = {
        allowed-commands-while-unauthorized = [
          "login"
          "register"
          "2fa"
          "2faconfirm"
        ];
        auto-register = false;
        database = {
          database = "minecraft";
          host = "localhost";
          max-life-time = 600000;
          password = "@DATABASE_PASSWORD@";
          port = 3306;
          user = "minecraft";
        };
        debug = false;
        default-crypto-provider = "BCrypt-2A";
        fallback = false;
        kick-on-wrong-password = false;
        limbo = ["auth"];
        migration = {};
        milliseconds-to-refresh-notification = 10000;
        minimum-password-length = -1;
        new-uuid-creator = "MOJANG";
        # Use the same config as velocity's "try" and "forced-hosts
        pass-through = let
          velocityCfg = config.services.minecraft-servers.servers.proxy.files."velocity.toml".value;
        in
          {
            root = velocityCfg.servers.try;
          }
          // (mapAttrs' (n: nameValuePair (replaceStrings ["."] ["§"] n)) velocityCfg.forced-hosts);
        ping-servers = true;
        remember-last-server = true;
        revision = 3;
        seconds-to-authorize = -1;
        session-timeout = 604800;
        totp.enabled = true;
        use-titles = false;
      };
      "plugins/librelogin/messages.conf".format = pkgs.formats.json {};
      "plugins/librelogin/messages.conf".value = {
        error-already-authorized = "&cVocê já está logado.";
        error-already-registered = "&cVocê já está registrado.";
        error-corrupted-configuration = "&cConfiguração corrompiada, mantendo a antiga. Motivo: %cause%";
        error-corrupted-messages = "C&configuração de mensagens corrompiada, mantendo a antiga. Motivo: %cause%";
        error-forbidden-password = "&cEssa senha é muito curta ou muito fácil de adivinha, tente outra.";
        error-from-floodgate = "&cVocê não pode usar esse comando na versão bedrock.";
        error-invalid-syntax = "Use: <c2>{command}</c2> <c3>{syntax}</c3>";
        error-no-confirm = "&cUse /premium <senha> antes.";
        error-no-permission = "&cVocê não tem permissão para usar esse comando.";
        error-not-authorized = "&cFaça login antes.";
        error-not-available-on-multi-proxy = "&cEssa funcionalidade não está disponível.";
        error-not-cracked = "&cSua conta está marcada como original, você pode marcar como pirata (desabilitando autologin) usando: &b/cracked";
        error-not-paid = "&cEssa conta não existe na base da Mojang.";
        error-not-premium = "&cSua conta está marcada como pirata, você pode marcá-la como original (habilitando autologin) usando: &b/premium <password>!";
        error-not-registered = "&cSe registre antes.";
        error-occupied-user = "&cEsse usuário já está em uso.";
        error-password-corrupted = "&cSua senha está corrompida, contate um administrador.";
        error-password-not-match = "&cAs duas senhas não batem, tente novamente.";
        error-password-wrong = "&cSenha incorreta, tente novamente.";
        error-player-authorized = "&cEsse jogador já está logado.";
        error-player-not-registered = "&cEsse jogador não está registrado.";
        error-player-offline = "&cEsse jogador não está online.";
        error-player-online = "&cEsse jogador está online.";
        error-premium-throttled = "&cO API da Mojang está com rate limit, aguarde alguns momentos e tente novamente.";
        error-premium-unknown = "&cHouve um erro ao contatar o API da Mojang, tente novamente mais tarde ou contate um admin.";
        error-throttle = "&cVocê está enviando comandos muito rápido. Aguarde um momento.";
        error-unknown = "&cUm erro desconhecido ocorreu, contate um admin.";
        error-unknown-command = "&cComando desconhecido.";
        error-unknown-user = "&cUsuário desconhecido.";
        info-deleted = "&aRemovido!";
        info-deleting = "Removendo...";
        info-disabling = "Desabilitando...";
        info-edited = "&aEditado com sucesso.";
        info-editing = "Editando...";
        info-enabling = "Habilitando...";
        info-kick = "&cVocê foi desconectado: &r%reason%";
        info-logged-in = "&aBem-vindo!";
        info-logging-in = "Fazendo login...";
        info-premium-logged-in = "&2Conta original autenticada automaticamente.";
        info-registered = "&aSucesso! Caso sua conta seja original, você pode ativar login automático usando: /premium";
        info-registering = "Registrando...";
        info-reloaded = "&aRecarregado!";
        info-reloading = "Recarregando...";
        info-session-logged-in = "&aSessão reestabelecida";
        info-user = "UUID: %uuid%\nPremium UUID: %premium_uuid%\nLast Seen: %last_seen%\nJoined: %joined%\n2FA: %2fa%\nIP: %ip%\nLast Authenticated: %last_authenticated%";
        kick-2fa-enabled = "&aAutenticação de dois fatores habilitada, faça login novamente.";
        kick-error-password-wrong = "&cSenha incorreta!";
        kick-illegal-username = "&cVocê tem caracteres inválidos no seu usuário ou ele tem mais de 16 caracteres.";
        kick-invalid-case-username = "&bPor favor, mude seu usuário para &e%username%";
        kick-name-mismatch = "Parece que um jogador com conta original está usando o nickname %nickname%, então há colisão. Contate um administrador.";
        kick-no-server = "&cNão há servidores disponíveis para conectar. Tente novamente mais tarde ou contate um admin.";
        kick-occupied-username = "&bPor favor, mude seu usuário para &e%username%";
        kick-premium-error-throttled = "&cO API da Mojang está com rate limit, tente entrar novamente em um instante.";
        kick-premium-error-undefined = "&cHouve um problema ao se conectar ao servidor da Mojang. Tente novamente ou contate um administrador.";
        kick-premium-info-disabled = "&aAutologin &4desabilitado&a!";
        kick-premium-info-enabled = "&aAutologin &2habilitado&a!";
        kick-time-limit = "&eVocê demorou muito para logar.";
        prompt-confirm = "&bVocê está marcando sua conta como original e habilitando autologin. Note que você &4NÃO PODERÁ&r se conectar a partir de um client pirata. Para confirmar, use: &e/confirmpremium";
        prompt-login = "&bPor favor, faça login usando: &e/login &6<senha>";
        prompt-register = "&bPor favor, se registre usando: &e/register &6<senha> <senha>";
        revision = 2;
        sub-title-login = "&e/login &b<senha>";
        sub-title-register = "&e/register &b<senha> <senha>";
        syntax = {
          "2fa-confirm" = "<código>";
          change-password = "<antigaSenha> <novaSenha>";
          login = "<senha> [totp]";
          premium = "<senha>";
          register = "<senha> <senha>";
          user-2fa-off = "<nome>";
          user-cracked = "<nome>";
          user-delete = "<nome>";
          user-info = "<nome>";
          user-login = "<nome>";
          user-migrate = "<nome> <novoNome>";
          user-pass-change = "<antigaSenha> <novaSenha>";
          user-premium = "<nome>";
          user-register = "<nome> <senha>";
          user-unregister = "<nome>";
        };
        title-login = "&6&lLogin";
        title-register = "&6&lRegistrar";
        totp-generating = "Gerando código 2FA...";
        totp-not-awaiting = "&cVocê não está no processo de habilitar 2FA. Use &e/2fa&c para começar.";
        totp-not-provided = "&cVocê deve fornecer um código TOTP. Se você perdeu seu autenticador, contate um administrador.";
        totp-show-info = "&bPor favor, escaneie o QR code no seu app de 2FA (google authenticator, authy, etc). \nQuando estiver tudo pronto use &e/2faconfirm <código>&b para finalizar.";
        totp-wrong = "&cCódigo TOTP incorreto!";
        totp-wrong-version = "Você precisa se conectar com um cliente %low% - %high% para habilitar o 2FA. Depois de habilitado, você pode voltar para essa versão.";
      };
    };
  };
}
