{ lib
, stdenv
, fetchFromGitHub
, buildNpmPackage
, makeWrapper

, coreutils
, ffmpeg-full
, imagemagick
, procps
, python3
, xorg

, withChromium ? (lib.elem stdenv.hostPlatform.system chromedriver.meta.platforms)
, chromedriver
, chromium

, withFirefox ? (lib.elem stdenv.hostPlatform.system geckodriver.meta.platforms)
, geckodriver
, firefox
}:
buildNpmPackage rec {
  pname = "sitespeedio";
  version = "27.3.1";

  src = fetchFromGitHub {
    owner = pname;
    repo = "sitespeed.io";
    rev = "v${version}";
    hash = "sha256-Z4U4ZIw5Du/VSHIsGKdgu7wRv/6XVh/nMFDs8aYwkOQ=";
  };

  nativeBuildInputs = [ python3 makeWrapper ];

  postPatch = ''
    ln -s npm-shrinkwrap.json package-lock.json
  '';

  # Don't try to download the browser drivers
  CHROMEDRIVER_SKIP_DOWNLOAD = true;
  GECKODRIVER_SKIP_DOWNLOAD = true;
  EDGEDRIVER_SKIP_DOWNLOAD = true;

  dontNpmBuild = true;
  npmInstallFlags = [ "--omit=dev" ];
  npmDepsHash = "sha256-Z9SSIPF/QPDsv4DexiqJAAXhY/QvnWqnauih6DT7I8o=";

  postInstall = ''
    mv $out/bin/sitespeed{.,}io
    mv $out/bin/sitespeed{.,}io-wpr
  '';

  postFixup =
  let
    chromiumArgs = lib.concatStringsSep " " [
      "--browsertime.chrome.chromedriverPath=${lib.getExe chromedriver}"
      "--browsertime.chrome.binaryPath=${lib.getExe chromium}"
    ];
    firefoxArgs = lib.concatStringsSep " " [
      "--browsertime.firefox.geckodriverPath=${lib.getExe geckodriver}"
      "--browsertime.firefox.binaryPath=${lib.getExe firefox}"
      "--browsertime.firefox.profileTemplate=$(mktemp -d)"
    ];
  in ''
    wrapProgram $out/bin/sitespeedio \
      --set PATH ${lib.makeBinPath ([
        (python3.withPackages (p: [p.numpy p.opencv4 p.pyssim]))
        ffmpeg-full
        imagemagick
        xorg.xorgserver
        procps
        coreutils
      ])} \
      ${lib.optionalString withChromium "--add-flags '${chromiumArgs}'"} \
      ${lib.optionalString withFirefox "--add-flags '${firefoxArgs}'"}
  '';

  meta = with lib; {
    description = "An open source tool that helps you monitor, analyze and optimize your website speed and performance";
    homepage = "https://sitespeed.io";
    license = licenses.mit;
    maintainers = with maintainers; [ misterio77 ];
    platforms = lib.unique (geckodriver.meta.platforms ++ chromedriver.meta.platforms);
  };
}
