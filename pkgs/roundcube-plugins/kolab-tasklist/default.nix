{php, fetchFromGitHub, ...}:
php.buildComposerProject2 {
  pname = "kolab-tasklist";
  version = "3.6.1";

  src = fetchFromGitHub {
    owner = "kolab-roundcube-plugins-mirror";
    repo = "tasklist";
    rev = "3.6.1";
    hash = "sha256-qmE3R09t2LpuMbKfrXryDR82DRfbckqVwPr5to12PcY=";
  };

  vendorHash = "sha256-nhohJBpv3+09PxX+WrHA3SoO2uCDqjEl1PRug3oUsIQ=";
  composerLock = ./composer.lock;
  composerStrictValidation = false;

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    ln -s $out/share/php/$pname/vendor $out/vendor

    mkdir -p $out/plugins
    ln -s $out/share/php/$pname $out/plugins/tasklist
    ln -s $out/vendor/kolab/{libcalendaring,libkolab} $out/plugins/

    runHook postInstall
  '';
}
