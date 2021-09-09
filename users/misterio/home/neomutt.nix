{ pkgs,... }:

{
  programs.neomutt = {
    enable = true;
    vimKeys = true;
    checkStatsInterval = 60;
    sidebar = {
      enable = true;
      width = 30;
    };
    settings = {
      mark_old = "no";
      text_flowed = "yes";
      reverse_name = "yes";
    };
    binds = [
      {
        action = "sidebar-toggle-visible";
        key = "\\\\";
        map = [ "index" "pager" ];
      }
    ];
    macros = [
      {
        action = "<sidebar-next><sidebar-open>";
        key = "J";
        map = [ "index" "pager" ];
      }
      {
        action = "<sidebar-prev><sidebar-open>";
        key = "K";
        map = [ "index" "pager" ];
      }
      {
        action = ":set confirmappend=no\\n<tag-prefix><save-message>+Archive<enter>:set confirmappend=yes\\n";
        key = "A";
        map = [ "index" "pager" ];
      }
    ];
    extraConfig = ''
      alternates "eu@misterio.me|gabriel.fontes@uget.express|g.fontes@usp.br"

      # From: https://github.com/altercation/mutt-colors-solarized/blob/master/mutt-colors-solarized-dark-16.muttrc

      # basic colors ---------------------------------------------------------
      color normal        brightyellow    default         
      color error         red             default         
      color tilde         black           default         
      color message       cyan            default         
      color markers       red             white           
      color attachment    white           default         
      color search        brightmagenta   default         
      color status        brightyellow    black           
      color indicator     brightblack     yellow          
      color tree          yellow          default                                     # arrow in threads

      # basic monocolor screen
      mono  bold          bold
      mono  underline     underline
      mono  indicator     reverse
      mono  error         bold

      # index ----------------------------------------------------------------

      color index         red             default         "~A"                        # all messages
      color index         brightred       default         "~E"                        # expired messages
      color index         blue            default         "~N"                        # new messages
      color index         blue            default         "~O"                        # old messages
      color index         brightmagenta   default         "~Q"                        # messages that have been replied to
      color index         brightgreen     default         "~R"                        # read messages
      color index         blue            default         "~U"                        # unread messages
      color index         blue            default         "~U~$"                      # unread, unreferenced messages
      color index         brightyellow    default         "~v"                        # messages part of a collapsed thread
      color index         brightyellow    default         "~P"                        # messages from me
      color index         cyan            default         "~p!~F"                     # messages to me
      color index         cyan            default         "~N~p!~F"                   # new messages to me
      color index         cyan            default         "~U~p!~F"                   # unread messages to me
      color index         brightgreen     default         "~R~p!~F"                   # messages to me
      color index         red             default         "~F"                        # flagged messages
      color index         red             default         "~F~p"                      # flagged messages to me
      color index         red             default         "~N~F"                      # new flagged messages
      color index         red             default         "~N~F~p"                    # new flagged messages to me
      color index         red             default         "~U~F~p"                    # new flagged messages to me
      color index         black           red             "~D"                        # deleted messages
      color index         brightcyan      default         "~v~(!~N)"                  # collapsed thread with no unread
      color index         yellow          default         "~v~(~N)"                   # collapsed thread with some unread
      color index         green           default         "~N~v~(~N)"                 # collapsed thread with unread parent
      color index         red             black           "~v~(~F)!~N"                # collapsed thread with flagged, no unread
      color index         yellow          black           "~v~(~F~N)"                 # collapsed thread with some unread & flagged
      color index         green           black           "~N~v~(~F~N)"               # collapsed thread with unread parent & flagged
      color index         green           black           "~N~v~(~F)"                 # collapsed thread with unread parent, no unread inside, but some flagged
      color index         cyan            black           "~v~(~p)"                   # collapsed thread with unread parent, no unread inside, some to me directly
      color index         yellow          red             "~v~(~D)"                   # thread with deleted (doesn't differentiate between all or partial)
      color index         yellow          default         "~(~N)"                     # messages in threads with some unread
      color index         green           default         "~S"                        # superseded messages
      color index         red             default         "~T"                        # tagged messages

      # message headers ------------------------------------------------------

      color hdrdefault    brightgreen     default         
      color header        brightyellow    default         "^(From)"
      color header        blue            default         "^(Subject)"

      # body -----------------------------------------------------------------

      color quoted        blue            default         
      color quoted1       cyan            default         
      color quoted2       yellow          default         
      color quoted3       red             default         
      color quoted4       brightred       default         

      color signature     brightgreen     default         
      color bold          black           default         
      color underline     black           default         
      color normal        default         default         
      color body          brightcyan      default         "[;:][-o][)/(|]"    # emoticons
      color body          brightcyan      default         "[;:][)(|]"         # emoticons
      color body          brightcyan      default         "[*]?((N)?ACK|CU|LOL|SCNR|BRB|BTW|CWYL|\
                                                           |FWIW|vbg|GD&R|HTH|HTHBE|IMHO|IMNSHO|\
                                                           |IRL|RTFM|ROTFL|ROFL|YMMV)[*]?"
      color body          brightcyan      default         "[ ][*][^*]*[*][ ]?" # more emoticon?
      color body          brightcyan      default         "[ ]?[*][^*]*[*][ ]" # more emoticon?

      ## pgp

      color body          red             default         "(BAD signature)"
      color body          cyan            default         "(Good signature)"
      color body          brightblack     default         "^gpg: Good signature .*"
      color body          brightyellow    default         "^gpg: "
      color body          brightyellow    red             "^gpg: BAD signature from.*"
      mono  body          bold                            "^gpg: Good signature"
      mono  body          bold                            "^gpg: BAD signature from.*"

      # yes, an insance URL regex
      color body          red             default         "([a-z][a-z0-9+-]*://(((([a-z0-9_.!~*'();:&=+$,-]|%[0-9a-f][0-9a-f])*@)?((([a-z0-9]([a-z0-9-]*[a-z0-9])?)\\.)*([a-z]([a-z0-9-]*[a-z0-9])?)\\.?|[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+)(:[0-9]+)?)|([a-z0-9_.!~*'()$,;:@&=+-]|%[0-9a-f][0-9a-f])+)(/([a-z0-9_.!~*'():@&=+$,-]|%[0-9a-f][0-9a-f])*(;([a-z0-9_.!~*'():@&=+$,-]|%[0-9a-f][0-9a-f])*)*(/([a-z0-9_.!~*'():@&=+$,-]|%[0-9a-f][0-9a-f])*(;([a-z0-9_.!~*'():@&=+$,-]|%[0-9a-f][0-9a-f])*)*)*)?(\\?([a-z0-9_.!~*'();/?:@&=+$,-]|%[0-9a-f][0-9a-f])*)?(#([a-z0-9_.!~*'();/?:@&=+$,-]|%[0-9a-f][0-9a-f])*)?|(www|ftp)\\.(([a-z0-9]([a-z0-9-]*[a-z0-9])?)\\.)*([a-z]([a-z0-9-]*[a-z0-9])?)\\.?(:[0-9]+)?(/([-a-z0-9_.!~*'():@&=+$,]|%[0-9a-f][0-9a-f])*(;([-a-z0-9_.!~*'():@&=+$,]|%[0-9a-f][0-9a-f])*)*(/([-a-z0-9_.!~*'():@&=+$,]|%[0-9a-f][0-9a-f])*(;([-a-z0-9_.!~*'():@&=+$,]|%[0-9a-f][0-9a-f])*)*)*)?(\\?([-a-z0-9_.!~*'();/?:@&=+$,]|%[0-9a-f][0-9a-f])*)?(#([-a-z0-9_.!~*'();/?:@&=+$,]|%[0-9a-f][0-9a-f])*)?)[^].,:;!)? \t\r\n<>\"]"
      # and a heavy handed email regex
      color body          magenta        default         "((@(([0-9a-z-]+\\.)*[0-9a-z-]+\\.?|#[0-9]+|\\[[0-9]?[0-9]?[0-9]\\.[0-9]?[0-9]?[0-9]\\.[0-9]?[0-9]?[0-9]\\.[0-9]?[0-9]?[0-9]\\]),)*@(([0-9a-z-]+\\.)*[0-9a-z-]+\\.?|#[0-9]+|\\[[0-9]?[0-9]?[0-9]\\.[0-9]?[0-9]?[0-9]\\.[0-9]?[0-9]?[0-9]\\.[0-9]?[0-9]?[0-9]\\]):)?[0-9a-z_.+%$-]+@(([0-9a-z-]+\\.)*[0-9a-z-]+\\.?|#[0-9]+|\\[[0-2]?[0-9]?[0-9]\\.[0-2]?[0-9]?[0-9]\\.[0-2]?[0-9]?[0-9]\\.[0-2]?[0-9]?[0-9]\\])"

      # Various smilies and the like
      color body          brightwhite     default         "<[Gg]>"                            # <g>
      color body          brightwhite     default         "<[Bb][Gg]>"                        # <bg>
      color body          yellow          default         " [;:]-*[})>{(<|]"                  # :-) etc...
      # *bold*
      color body          blue            default         "(^|[[:space:][:punct:]])\\*[^*]+\\*([[:space:][:punct:]]|$)"
      mono  body          bold                            "(^|[[:space:][:punct:]])\\*[^*]+\\*([[:space:][:punct:]]|$)"
      # _underline_
      color body          blue            default         "(^|[[:space:][:punct:]])_[^_]+_([[:space:][:punct:]]|$)"
      mono  body          underline                       "(^|[[:space:][:punct:]])_[^_]+_([[:space:][:punct:]]|$)"
      # /italic/  (Sometimes gets directory names)
      color body         blue            default         "(^|[[:space:][:punct:]])/[^/]+/([[:space:][:punct:]]|$)"
      mono body          underline                       "(^|[[:space:][:punct:]])/[^/]+/([[:space:][:punct:]]|$)"

      # Border lines.
      color body          blue            default         "( *[-+=#*~_]){6,}"
    '';
  };
  programs.mbsync.enable = true;
  programs.msmtp.enable = true;
  systemd.user.services.mbsync = {
    Unit = {
      Description = "mbsync synchronization";
    };
    Service = {
      Type = "oneshot";
      ExecCondition = ''
        /bin/sh -c '${pkgs.gnupg}/bin/gpg-connect-agent "KEYINFO --no-ask B5076D6AB0783A842150876E8047AEE5604FB663 Err Pmt Des" /bye | grep " 1 "'
      '';
      ExecStart = "${pkgs.isync}/bin/mbsync -a";
    };
  };
  systemd.user.timers.mbsync = {
    Unit = {
      Description = "Automatic mbsync synchronization";
    };
    Timer = {
      OnBootSec = "30";
      OnUnitActiveSec = "1m";
    };
    Install = { WantedBy = [ "timers.target" ]; };
  };
}
