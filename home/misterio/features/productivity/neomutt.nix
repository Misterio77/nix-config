{ config, pkgs, lib, ... }: {
  xdg = {
    desktopEntries = {
      neomutt = {
        name = "Neomutt";
        genericName = "Email Client";
        comment = "Read and send emails";
        exec = "neomutt %U";
        icon = "mutt";
        terminal = true;
        categories = [ "Network" "Email" "ConsoleOnly" ];
        type = "Application";
        mimeType = [ "x-scheme-handler/mailto" ];
      };
    };
    mimeApps.defaultApplications = {
      "x-scheme-handler/mailto" = "neomutt.desktop";
    };
  };

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
      query_command = ''"khard email --parsable '%s'"'';
    };
    binds = [
      {
        action = "sidebar-toggle-visible";
        key = "\\\\";
        map = [ "index" "pager" ];
      }
      {
        action = "group-reply";
        key = "L";
        map = [ "index" "pager" ];
      }
      {
        action = "toggle-new";
        key = "B";
        map = [ "index" ];
      }
    ];
    macros =
      let
        browserpipe =
          "cat /dev/stdin > /tmp/muttmail.html && xdg-open /tmp/muttmail.html";
      in
      [
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
          action =
            ":set confirmappend=no\\n<save-message>+Archive<enter>:set confirmappend=yes\\n";
          key = "A";
          map = [ "index" "pager" ];
        }
        {
          action = "<pipe-entry>${browserpipe}<enter><exit>";
          key = "V";
          map = [ "attach" ];
        }
        {
          action = "<pipe-message>${pkgs.urlscan}/bin/urlscan<enter><exit>";
          key = "F";
          map = [ "pager" ];
        }
        {
          action =
            "<view-attachments><search>html<enter><pipe-entry>${browserpipe}<enter><exit>";
          key = "V";
          map = [ "index" "pager" ];
        }
      ];
    extraConfig = let
      # Collect all addresses and aliases
      addresses = lib.flatten (lib.mapAttrsToList (n: v: [ v.address ] ++ v.aliases) config.accounts.email.accounts);
    in ''
      alternates "${lib.concatStringsSep "|" addresses}"
    '' + ''
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
      color tree          cyan            default                                     # arrow in threads

      # basic monocolor screen
      mono  bold          bold
      mono  underline     underline
      mono  indicator     reverse
      mono  error         bold

      # index ----------------------------------------------------------------

      color index         red             default         "~A"                        # all messages
      color index         blue            default         "~N"                        # new messages
      color index         brightred       default         "~E"                        # expired messages
      color index         blue            default         "~N"                        # new messages
      color index         blue            default         "~O"                        # old messages
      color index         brightmagenta   default         "~Q"                        # messages that have been replied to
      color index         brightgreen     default         "~R"                        # read messages
      color index         blue            default         "~U"                        # unread messages
      color index         blue            default         "~U~$"                      # unread, unreferenced messages
      color index         cyan            default         "~v"                        # messages part of a collapsed thread
      color index         magenta         default         "~P"                        # messages from me
      color index         cyan            default         "~p!~F"                     # messages to me
      color index         cyan            default         "~N~p!~F"                   # new messages to me
      color index         cyan            default         "~U~p!~F"                   # unread messages to me
      color index         brightgreen     default         "~R~p!~F"                   # messages to me
      color index         red             default         "~F"                        # flagged messages
      color index         red             default         "~F~p"                      # flagged messages to me
      color index         red             default         "~N~F"                      # new flagged messages
      color index         red             default         "~N~F~p"                    # new flagged messages to me
      color index         red             default         "~U~F~p"                    # new flagged messages to me
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
      color index         black           red             "~D"                        # deleted messages
      color index         black           red             "~N~D"                      # deleted messages
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

      # From https://github.com/jessfraz/dockerfiles/blob/master/mutt/.mutt/mutt-patch-highlighting.muttrc
      color   body    cyan            default         ^(Signed-off-by).*
      color   body    cyan            default         ^(Docker-DCO-1.1-Signed-off-by).*
      color   body    brightwhite     default         ^(Cc)
      color   body    yellow          default         "^diff \-.*"
      color   body    brightwhite     default         "^index [a-f0-9].*"
      color   body    brightblue      default         "^---$"
      color   body    white           default         "^\-\-\- .*"
      color   body    white           default         "^[\+]{3} .*"
      color   body    green           default         "^[\+][^\+]+.*"
      color   body    red             default         "^\-[^\-]+.*"
      color   body    brightblue      default         "^@@ .*"
      color   body    green           default         "LGTM"
      color   body    brightmagenta   default         "-- Commit Summary --"
      color   body    brightmagenta   default         "-- File Changes --"
      color   body    brightmagenta   default         "-- Patch Links --"
    '';
  };
}
