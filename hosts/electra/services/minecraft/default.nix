{ inputs, pkgs, outputs, config, lib, ... }:
let
  papermc = pkgs.callPackage ./pkgs/papermc.nix { };
  velocity = pkgs.callPackage ./pkgs/velocity.nix { };
  lib' = import ./lib.nix { inherit pkgs; };
in
{
  imports = [ inputs.nix-minecraft.nixosModules.minecraft-servers ];

  services.minecraft-servers = {
    enable = true;
    eula = true;
    servers = {

      proxy = {
        enable = true;
        package = velocity;
        jvmOpts = lib'.proxyFlags "512M";
        openFirewall = true;
        files = {
          "velocity.toml" = lib'.toTOMLFile {
            config-version = "2.5";
            bind = "0.0.0.0:25565";
            motd = "Server do Misterinho";
            player-info-forwarding-mode = "modern";
            forwarding-secret-file = config.sops.secrets.velocity-forwarding-secret.path;
            online-mode = true;
            servers = {
              survival = "localhost:25560";
              try = [ "survival" ];
            };
            forced-hosts = { };
            query = {
              enabled = true;
              port = 25565;
            };
          };
          "plugins/limboapi/config.yml" = lib'.toYAMLFile {
            prefix = "Limbo";
            main.check-for-updates = false;
          };
          "plugins/limboauth/config.yml" = lib'.toYAMLFile {
            prefix = "Auth";
            main = {
              auth-time = 0;
              enable-bossbar = false;
              online-mode-need-auth = false;
              floodgate-need-auth = false;
              save-premium-accounts = false;
              enable-totp = false;
              register-need-repeat-password = false;
              strings = {
                reload = "&aRecarregado com sucesso.";
                error-occurred = "&cUm erro interno ocorreu.";
                database-error-kick = "&cUm erro de base de dados ocorreu.";
                not-player = "&cO console não pode executar esse comando.";
                not-registered = "&cVocê não esta registrado ou tem uma conta paga.";
                cracked-command = "{NL}&aVocê não pode usar este comando, pois tem uma conta paga.";
                wrong-password = "&cSenha incorreta.";
                nickname-invalid-kick = "{NL}&cSeu nome possui caracteres inválidos. Retire-os, por favor!.";
                reconnect-kick = "{NL}&cReconecte para verificar sua conta.";
                ip-limit-kick = "{NL}{NL}&cSeu IP chegou ao máximo de registros.";
                wrong-nickname-case-kick = "{NL}&cVocẽ deve entrar usando o nickname &6{0}&c ao invés de &6{1}&c.";
                bossbar = "Você tem &6{0} &fsegundos para fazer login.";
                times-up = "{NL}&cVocê demorou muito para fazer login.";
                login-premium = "&2Conta original autenticada automaticamente.";
                login-premium-title = "";
                login-premium-subtitle = "";
                login-floodgate = "&2Conta original autenticada automaticamente.";
                login-floodgate-title = "";
                login-floodgate-subtitle = "";
                login = "&aPor favor, faça login usando &6/login <senha>&a, você tem &6{0} &atentativas.";
                login-wrong-password = "&cSenha incorreta, você tem mais &6{0} &ctentativas.";
                login-wrong-password-kick = "{NL}&cVocê errou a senha muitas vezes, tente novamente.";
                login-successful = "&aAutenticado com sucesso.";
                login-title = "";
                login-subtitle = "";
                login-successful-title = "";
                login-successful-subtitle = "";
                register = "Por favor, registre sua conta usando &6/register <senha>";
                register-different-passwords = "&cAs senhas inseridas não batem.";
                register-password-too-short = "&cEssa senha é muito curta, tente uma maior.";
                register-password-too-long = "&cEssa senha é muito longa, tente uma menor.";
                register-password-unsafe = "&cEssa senha é muito fácil, tente outra.";
                register-successful = "&aRegistrado com sucesso.";
                register-title = "";
                register-subtitle = "";
                register-successful-title = "";
                register-successful-subtitle = "";
                unregister-successful = "{NL}&aDesregistrado com sucesso.";
                unregister-usage = "Usagem: &6/unregister <senha> confirm";
                premium-successful = "{NL}&aConta marcada como &6original&a.";
                already-premium = "&cSua conta já está marcada como &6original&c.";
                not-premium = "&cSua conta não é &6original&c.";
                premium-usage = "Usagem: &6/premium <senha> confirm";
                event-cancelled = "Evento de autorização cancelado";
                force-unregister-successful = "&6{0} &aderesgistrado.";
                force-unregister-kick = "{NL}&aVocê foi desregistrado pelo admin.";
                force-unregister-not-successful = "&cNão foi possível desregistrar &6{0}&c.";
                force-unregister-usage = "Usagem: &6/forceunregister <nickname>";
                registrations-disabled-kick = "Registros estão desabilitados no momento.";
                change-password-successful = "&aSenha alterada com sucesso.";
                change-password-usage = "Usagem: &6/changepassword <senha antiga> <senha nova>";
                force-change-password-successful = "&aSenha de &6{0}&a alterada com sucesso.";
                force-change-password-message = "&aSua senha foi alterada para &6{0} &apelo admin.";
                force-change-password-not-successful = "&cNão foi possível alterar a senha de &6{0}&c.";
                force-change-password-usage = "Usagem: &6/forcechangepassword <nickname> <senha nova>";
                totp = "Por favor, digita seu código 2FA usando &6/2fa <codigo>";
                totp-title = "";
                totp-subtitle = "";
                totp-successful = "&a2FA habilitado com sucesso.";
                totp-disabled = "&a2FA desabilitado com sucesso.";
                totp-usage = "Usagem: &6/2fa enable <senha atual>&f ou &6/2fa disable <chave totp>&f.";
                totp-wrong = "&cChave 2FA incorreta!";
                totp-already-enabled = "&c2FA já está habilitado. Você pode desabilitar com &6/2fa disable <chave>&c.";
                totp-qr = "Clique aqui para abrir o QR Code em seu navegador.";
                totp-token = "&aSeu token 2FA &7(clique para copiar)&a: &6{0}";
                totp-recovery = "&aSeus códigos de recuperação&7(clique para copiar)&a: &6{0}";
                destroy-session-successful = "&eSessão removida. Você terá que logar novamente ao reconectar.";
              };
            };
            database.storage-type = "sqlite";
          };
        };
        symlinks = {
          "plugins/LimboAPI.jar" = pkgs.fetchurl rec {
            pname = "LimboAPI";
            version = "1.0.8";
            url = "https://github.com/Elytrium/${pname}/releases/download/1.0.8/${pname}-plugin-${version}-jdk17.jar";
            sha256 = "sha256-qGBBHSEGdUXLDQkCBKn5N28/9Zlazu8/fYrAIvlb0EA=";
          };
          "plugins/LimboAuth.jar" = pkgs.fetchurl rec {
            pname = "LimboAuth";
            version = "1.0.8";
            url = "https://github.com/Elytrium/${pname}/releases/download/1.0.8/${pname}-${version}-jdk17.jar";
            sha256 = "sha256-S1u7QHF0n6EhGq++VF7BlbaJ4Y8xpQWR2BuGQBeW+r8=";
          };
          "plugins/Geyser.jar" = pkgs.fetchurl rec {
            pname = "Geyser";
            version = "1269";
            url = "https://ci.opencollab.dev/job/GeyserMC/job/${pname}/job/master/${version}/artifact/bootstrap/velocity/build/libs/${pname}-Velocity.jar";
            sha256 = "sha256-SKXX/8D9XKKrLZCNfiB31FoPmwbB/cpthz3Lu6yr7FU=";
          };
          "plugins/Floodgate.jar" = pkgs.fetchurl rec {
            pname = "Floodgate";
            version = "74";
            url = "https://ci.opencollab.dev/job/GeyserMC/job/${pname}/job/master/${version}/artifact/velocity/build/libs/${lib.toLower pname}-velocity.jar";
            sha256 = "sha256-yFVVtyqhtSRt/r+i0uSu9HleDmAp+xwAAdWmV4W8umU=";
          };
        };
      };

      survival = {
        enable = true;
        package = papermc;
        jvmOpts = lib'.aikarFlags "1G";
        serverProperties = {
          server-port = 25560;
          online-mode = false;
        };
        files = {
          "config/paper-global.yml" = lib'.toYAMLFile {
            proxies.velocity = {
              enabled = true;
              online-mode = false;
              secret-file = config.sops.secrets.velocity-forwarding-secret.path;
            };
          };
        };
        symlinks = {
          "plugins/ViaVersion.jar" = pkgs.fetchurl rec {
            pname = "ViaVersion";
            version = "4.5.1";
            url = "https://github.com/ViaVersion/${pname}/releases/download/${version}/${pname}-${version}.jar";
            sha256 = "sha256-hMxl5QyMxNL/vx58Jz0tJ8E/SlJ3w7sIvm8Dc70GBXQ=";
          };
          "plugins/ViaBackwards.jar" = pkgs.fetchurl rec {
            pname = "ViaBackwards";
            version = "4.5.1";
            url = "https://github.com/ViaVersion/${pname}/releases/download/${version}/${pname}-${version}.jar";
            sha256 = "sha256-wugRc0J2+oche6pI0n97+SabTOmGGDvamBItbl1neuU=";
          };
        };
      };
    };
  };

  sops.secrets = {
    velocity-forwarding-secret = {
      owner = "minecraft";
      group = "minecraft";
      sopsFile = ../../secrets.yaml;
    };
  };
}
