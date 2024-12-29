{pkgs, ...}: {
  services.minecraft-servers.servers.proxy = {
    extraReload = ''
      echo 'huskchat reload' > /run/minecraft/proxy.stdin
    '';
    symlinks = {
      "plugins/HuskChat.jar" = pkgs.fetchurl rec {
        pname = "HuskChat";
        version = "2.7.1";
        url = "https://github.com/WiIIiam278/${pname}/releases/download/${version}/${pname}-${version}.jar";
        hash = "sha256-Vg0xu2Z7WeeabK1r5qOw9STcK9kxA5ApshljyXDUy7M=";
      };
      "plugins/UnSignedVelocity.jar" = pkgs.fetchurl rec {
        pname = "UnSignedVelocity";
        version = "1.4.2";
        url = "https://github.com/4drian3d/${pname}/releases/download/${version}/${pname}-${version}.jar";
        hash = "sha256-i6S05M4mGxnp4tJmR4AKFOBgEQb7d5mTH95nryA7v0A=";
      };
      "plugins/VPacketEvents.jar" = pkgs.fetchurl rec {
        pname = "VPacketEvents";
        version = "1.1.0";
        url = "https://github.com/4drian3d/${pname}/releases/download/${version}/${pname}-${version}.jar";
        hash = "sha256-qWHR8hn56vf8csUDhuzV8WPBhZtaJE+uLNqupcJvGEI=";
      };
    };
    files = {
      "plugins/huskchat/config.yml".value = {
        config-version = 2;
        check_for_updates = false;
        default_channel = "default";
        channel_log_format = "[CHAT] [%channel%] %sender%: ";
        channel_command_aliases = [
          "/channel"
          "/c"
        ];

        channels = {
          default = {
            format = "&7[%servername%] %fullname%&r&f: ";
            broadcast_scope = "GLOBAL";
            log_to_console = true;
            shortcut_commands = [
              "/global"
              "/g"
              "/default"
              "/d"
            ];
          };
          internal = {
            format = "%fullname%&r&0: ";
            broadcast_scope = "PASSTHROUGH";
            shortcut_commands = [
              "/i"
              "/internal"
            ];
          };
        };
        broadcast_command = {
          enabled = true;
          broadcast_aliases = [
            "/broadcast"
            "/alert"
          ];
          format = "&4[SERVER]&e ";
          log_to_console = true;
          log_format = "[SERVER]: ";
        };
        message_command = {
          enabled = true;
          msg_aliases = [
            "/msg"
            "/m"
            "/tell"
            "/whisper"
            "/w"
            "/pm"
          ];
          reply_aliases = [
            "/reply"
            "/r"
          ];
          log_to_console = true;
          log_format = "[MSG] [%sender% -> %receiver%]: ";
          group_messages.enabled = false;
          format = {
            inbound = "&#00fb9a&%name% &8→ &#00fb9a&Você&8: &f";
            outbound = "&#00fb9a&Você &8→ &#00fb9a&%name%&8: &f";
          };
        };
        social_spy.enabled = false;
        local_spy.enabled = false;
        chat_filters = {
          advertising_filter.enabled = false;
          caps_filter.enabled = false;
          spam_filter.enabled = false;
          profanity_filter.enabled = false;
          repeat_filter.enabled = false;
          ascii_filter.enabled = false;
        };
        message_replacers.emoji_replacer.enabled = false;
        discord.enabled = false;
        join_and_quit_messages = {
          join = {
            enabled = true;
            format = "&f%name%&e entrou no servidor";
          };
          quit = {
            enabled = true;
            format = "&f%name%&e saiu do servidor";
          };
          broadcast_scope = "GLOBAL";
        };
      };
      "plugins/huskchat/messages-en-gb.yml".value = {
        error_no_permission = "[Erro:](#ff3300) [Você não tem permissão para usar esse comando.](#ff7e5e)";
        error_invalid_syntax = "[Erro:](#ff3300) [Sintaxe inválida. Usagem: %1%](#ff7e5e)";
        channel_switched = "[Você agora está no canal](#00fb9a) [%1%](#eecc55 bold) [!](#00fb9a)";
        error_no_permission_send = "[Erro:](#ff3300) [Você não tem permissão para usar esse chat.](#ff7e5e)";
        error_invalid_channel = "[Erro:](#ff3300) [Especifique um canal válido.](#ff7e5e)";
        error_invalid_channel_command = "[Erro:](#ff3300) [Esse canal é inválido.](#ff7e5e)";
        error_no_channel = "[Erro:](#ff3300) [Você tentou falar em um canal inválido.](#ff7e5e) [Use /channel para trocar.](#ff7e5e show_text=&#ff7e5e&Click here to suggest command suggest_command=/channel )";
        error_player_not_found = "[Erro:](#ff3300) [Jogador não encontrado.](#ff7e5e)";
        error_cannot_message_self = "[Erro:](#ff3300) [Você não pode conversar com si mesmo, esquisito!](#ff7e5e)";
        error_reply_no_messages = "[Erro:](#ff3300) [Não há nenhuma mensagem para responder.](#ff7e5e)";
        error_reply_not_online = "[Erro:](#ff3300) [Essa pessoa não está mais online.](#ff7e5e)";
        error_message_restricted_server = "[Erro:](#ff3300) [Você não pode enviar mensagens enquanto está nesse servidor.](#ff7e5e)";
        error_message_recipient_restricted_server = "[Erro:](#ff3300) [Esse jogador está em um servidor onde mensagens não podem ser lidas.](#ff7e5e)";
        error_channel_restricted_server = "[Erro:](#ff3300) [Você não pode usar o chat %1% enquanto está nesse servidor.](#ff7e5e)";
        social_spy_toggled_on = "[Você agora está espionando chats privados.](#00fb9a)";
        social_spy_toggled_on_color = "[Você agora está espionando chats privados em](#00fb9a) %1%%2%";
        social_spy_toggled_off = "[Você não está mais espionando chats privados.](#00fb9a)";
        local_spy_toggled_on = "[Você agora está espionando mensagens locais de outros servidores.](#00fb9a)";
        local_spy_toggled_on_color = "[Você agora está mais espionando mensagens locais de](#00fb9a) %1%%2%";
        local_spy_toggled_off = "[Você não está mais espionando mensagens locais.](#00fb9a)";
        error_chat_filter_advertising = "[Você não pode fazer propagandas ou enviar links nesse chat.](#ff7e5e)";
        error_chat_filter_profanity = "[Você não pode xingar nesse chat.](#ff7e5e)";
        error_chat_filter_caps = "[Cuidado com o caps.](#ff7e5e)";
        error_chat_filter_spam = "[Opa! Mande mensagens um pouco mais devagarinho.](#ff7e5e)";
        error_chat_filter_ascii = "[Você não pode usar caracteres especiais no chat.](#ff7e5e)";
        error_chat_filter_repeat = "[Você já enviou essa mensagem recentemente!](#ff7e5e)";
        error_in_game_only = "Erro: Esse comando só pode ser usado dentro do jogo.";
        error_console_local_scope = "Erro: Enviar mensagens do console para chats locais não é possível.";
        error_console_switch_channels = "Erro: Você não pode mudar de canal pelo console.";
        error_group_messages_disabled = "[Erro:](#ff3300) [Você não pode enviar mensagens para múltiplas pessoas.](#ff7e5e)";
        error_group_messages_max = "[Erro:](#ff3300) [Seu chat pode ter no máximo %1% pessoas.](#ff7e5e)";
        error_players_not_found = "[Erro:](#ff3300) [Jogadores não encontrados.](#ff7e5e)";
        error_reply_none_online = "[Erro:](#ff3300) [Ninguém no último chat está online.](#ff7e5e)";
        error_last_message_not_group = "[Erro:](#ff3300) [A última mensagem não foi um chat de grupo.](#ff7e5e)";
        error_no_messages_opt_out = "[Erro:](#ff3300) [Você ainda não enviou ou recebeu mensagens em grupo.](#ff7e5e)";
        removed_from_group_message = "[Você saiu do chat em grupo com:](#00fb9a) %1%";
        list_conjunction = "e";
        error_passthrough_shortcut_command_error = "[Erro:](#ff3300) [Enviar mensagens para canais de passthrough usando atalhos não é possível. Troque para o canal usando o comando /channel](#ff7e5e)";
        up_to_date = "HuskChat: Você está na última versão (v%1%).";
        update_available = "HuskChat: Uma nova versão (v%1%) está disponível (atual: v%2%).";
      };
    };
  };
}
