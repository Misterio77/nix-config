{ lib, stdenv, fetchFromGitLab, dtc, installShellFiles }:

stdenv.mkDerivation rec {
  pname = "argononed";
  version = "unstable-2021-09-29";
  src = fetchFromGitLab {
    owner = "DarkElvenAngel";
    repo = pname;
    rev = "ee3df279f7954a8020313f5be15a2f9db0b71341";
    sha256 = "sha256-iReXZ/OQq5F6bYl90ET3zJ3yNWv/LlndS3UHhs4K1eM=";
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
