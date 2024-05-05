{
  lib,
  stdenvNoCC,
  makeWrapper,
  scdoc,
  coreutils,
  grim,
  jq,
  libnotify,
  slurp,
  wl-clipboard,
  hyprpicker,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation {
  pname = "grimblast";
  version = "0.1";

  src = fetchFromGitHub {
    owner = "hyprwm";
    repo = "contrib";
    rev = "110e6dc761d5c3d352574def3479a9c39dfc4358";
    hash = "sha256-DDAYNGSnrBwvVfpKx+XjkuecpoE9HiEf6JW+DBQgvm0=";
  };
  sourceRoot = "source/grimblast";

  nativeBuildInputs = [
    makeWrapper
  ];

  buildInputs = [
    scdoc
  ];

  makeFlags = ["PREFIX=$(out)"];

  postInstall = ''
    wrapProgram $out/bin/grimblast --prefix PATH ':' \
      "${lib.makeBinPath [
        coreutils
        grim
        jq
        libnotify
        slurp
        wl-clipboard
        hyprpicker
      ]}"
  '';

  meta = with lib; {
    description = "A helper for screenshots within Hyprland, based on grimshot";
    license = licenses.mit;
    platforms = platforms.unix;
    maintainers = with maintainers; [misterio77];
    mainProgram = "grimblast";
  };
}
