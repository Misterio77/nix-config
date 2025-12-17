{php, fetchFromGitHub, ...}:
php.buildComposerProject2 {
  pname = "kolab-calendar";
  version = "3.6.1";

  src = fetchFromGitHub {
    owner = "kolab-roundcube-plugins-mirror";
    repo = "calendar";
    rev = "3.6.1";
    hash = "sha256-arXPB/ZnV+8JN8XWC/yQA2jqKsP1TS2sVopti6TFpNA=";
  };

  vendorHash = "sha256-y4h3jduQKlg5Z95A32GOT8DiLa/ys09lduMtWe6wLQM=";
  composerLock = ./composer.lock;
  composerNoPlugins = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    ln -s $out/share/php/$pname/vendor $out/vendor

    mkdir -p $out/plugins
    ln -s $out/share/php/$pname $out/plugins/calendar
    ln -s $out/vendor/kolab/{libcalendaring,libkolab} $out/plugins/

    runHook postInstall
  '';
}
