{ lib, stdenv, writeShellScriptBin, jq, xmlstarlet }:

with lib;

stdenv.mkDerivation {
  name = "unread-mail";
  version = "1.0";
  src = writeShellScriptBin "unread-mail" ''
    count=$(find ~/Mail/*/INBOX/new -type f | wc -l)
    if [ "$count" == "0" ]; then
      subjects="No new mail"
      icon="read"
    else
      subjects=$(grep -h "Subject: " -r ~/Mail/*/INBOX/new | cut -d ':' -f2- | perl -CS -MEncode -ne 'print decode("MIME-Header", $_)' | ${xmlstarlet}/bin/xml esc | sed -e 's/^/\-/')
      icon="unread"
    fi
    ${jq}/bin/jq -cn --arg tooltip "$subjects" --arg text "$count" --arg alt "$icon" '{tooltip: $tooltip, text: $text, alt: $alt}'
  '';
  dontBuild = true;
  dontConfigure = true;
  installPhase =
    "install -Dm 0755 $src/bin/unread-mail $out/bin/unread-mail";

  meta = {
    description = "A script for getting unread email";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = with maintainers; [ misterio77 ];
  };
}

