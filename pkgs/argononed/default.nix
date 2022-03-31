{ lib, stdenv, fetchFromGitLab, dtc, installShellFiles }:

stdenv.mkDerivation rec {
  pname = "argononed";
  version = "0.4.x-2022-03-31";
  src = fetchFromGitLab {
    owner = "DarkElvenAngel";
    repo = pname;
    rev = "fe5753310bcc735818c8fe7d2a2ba397741c6f7b";
    sha256 = "sha256-7NY+gIOLK7vrjVBpr5eUDpbk9vEcO5muVyR4brfp2mg=";
  };

  nativeBuildInputs = [ installShellFiles ];

  buildInputs = [ dtc ];

  patchPhase = ''
    patchShebangs configure
  '';

  installPhase = ''
    install -Dm755 build/argononed $out/bin/argononed
    install -Dm755 build/argonone-cli $out/bin/argonone-cli
    install -Dm755 build/argonone-shutdown $out/lib/systemd/system-shutdown/argonone-shutdown
    install -Dm644 build/argonone.dtbo $out/boot/overlays/argonone.dtbo

    install -Dm644 OS/_common/argononed.service $out/lib/systemd/system/argononed.service
    install -Dm644 OS/_common/argononed.logrotate $out/etc/logrotate.d/argononed
    install -Dm644 LICENSE $out/share/argononed/LICENSE

    installShellCompletion --bash --name argonone-cli OS/_common/argonone-cli-complete.bash
  '';

  meta = with lib; {
    homepage = "https://gitlab.com/DarkElvenAngel/argononed";
    description = "A replacement daemon for the Argon One Raspberry Pi case";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
