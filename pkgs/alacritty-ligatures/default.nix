{ stdenv, lib, fetchFromGitHub, fetchpatch, rustPlatform

, cmake, gzip, installShellFiles, makeWrapper, ncurses, pkg-config, python3, harfbuzz

, expat, fontconfig, freetype, libGL, libX11, libXcursor, libXi, libXrandr
, libXxf86vm, libxcb, libxkbcommon, wayland, xdg-utils, zlib }:
let
  rpathLibs = [
    expat
    fontconfig
    freetype
    libGL
    libX11
    libXcursor
    libXi
    libXrandr
    libXxf86vm
    libxcb
  ] ++ lib.optionals stdenv.isLinux [ libxkbcommon wayland zlib ];
in rustPlatform.buildRustPackage rec {
  pname = "alacritty";
  version = "master";

  src = fetchFromGitHub {
    owner = "fee1-dead";
    repo = pname;
    rev = "6cd8751f3b68622c6978c3f20960b1925038aa24";
    sha256 = "sha256-z8e8Y+DF4mIPNgKkqIoDrI7uavHbdsBdTe7nKL6HzK0=";
  };

  cargoSha256 = "sha256-arEGZLZuzVAclplEssvaZypcLgjP3ffUUY4sDN7dG5Q=";

  nativeBuildInputs =
    [ cmake gzip installShellFiles makeWrapper ncurses pkg-config python3 harfbuzz ];

  buildInputs = rpathLibs;

  outputs = [ "out" "terminfo" ];

  postPatch = ''
    substituteInPlace alacritty/src/config/ui_config.rs \
      --replace xdg-open ${xdg-utils}/bin/xdg-open
  '';

  # TODO find out why tests fail
  doCheck = false;

  postInstall = ''
    install -D extra/linux/Alacritty.desktop -t $out/share/applications/
    install -D extra/linux/io.alacritty.Alacritty.appdata.xml -t $out/share/appdata/
    install -D extra/logo/compat/alacritty-term.svg $out/share/icons/hicolor/scalable/apps/Alacritty.svg
    # patchelf generates an ELF that binutils' "strip" doesn't like:
    #    strip: not enough room for program headers, try linking with -N
    # As a workaround, strip manually before running patchelf.
    strip -S $out/bin/alacritty
    patchelf --set-rpath "${lib.makeLibraryPath rpathLibs + ":${stdenv.cc.cc.lib}/lib64"}" $out/bin/alacritty
  '' + ''
    installShellCompletion --zsh extra/completions/_alacritty
    installShellCompletion --bash extra/completions/alacritty.bash
    installShellCompletion --fish extra/completions/alacritty.fish
    install -dm 755 "$out/share/man/man1"
    gzip -c extra/alacritty.man > "$out/share/man/man1/alacritty.1.gz"
    install -Dm 644 alacritty.yml $out/share/doc/alacritty.yml
    install -dm 755 "$terminfo/share/terminfo/a/"
    tic -xe alacritty,alacritty-direct -o "$terminfo/share/terminfo" extra/alacritty.info
    mkdir -p $out/nix-support
    echo "$terminfo" >> $out/nix-support/propagated-user-env-packages
  '';

  dontPatchELF = true;

  meta = with lib; {
    description = "A cross-platform, GPU-accelerated terminal emulator";
    homepage = "https://github.com/alacritty/alacritty";
    license = licenses.asl20;
    maintainers = with maintainers; [ Br1ght0ne mic92 ma27 ];
    platforms = platforms.unix;
    changelog =
      "https://github.com/alacritty/alacritty/blob/v${version}/CHANGELOG.md";
  };
}
