{ lib
, fetchFromGitHub
, buildNpmPackage
, makeWrapper

, coreutils
, ffmpeg-full
, imagemagick
, procps
, python3
, xorg

, withChromium ? true
, chromedriver
, chromium

, withFirefox ? true
, geckodriver
, firefox
}:
buildNpmPackage rec {
  pname = "sitespeedio";
  version = "27.3.0";

  src = fetchFromGitHub {
    owner = pname;
    repo = "sitespeed.io";
    rev = "v${version}";
    sha256 = "sha256-7CnoKmyoNIO+ovPsChbuZiyD7n2llMSZAgjMSb867H8=";
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
  npmDepsHash = "sha256-QYVMyPR1iJYyCmZE/qK7CgvL1Obb7TrHxgUrh2n2+6Q=";

  postInstall = ''
    mv $out/bin/sitespeed{.,}io
    mv $out/bin/sitespeed{.,}io-wpr
  '';

  postFixup =
  let
    firefoxArgs =
      "--chrome.chromedriverPath ${lib.getExe chromedriver} --chrome.binaryPath ${lib.getExe chromium}";
    chromiumArgs =
      "--browsertime.firefox.geckodriverPath ${lib.getExe geckodriver} --browsertime.firefox.binaryPath ${lib.getExe firefox}";
  in ''
    wrapProgram $out/bin/sitespeedio --set PATH ${
      lib.makeBinPath ([
        (python3.withPackages (p: [p.numpy p.opencv4 p.pyssim]))
        ffmpeg-full
        imagemagick
        xorg.xorgserver
        procps
        coreutils
      ] ++ lib.optionals withChromium [
        chromedriver
        chromium
      ] ++ lib.optionals withFirefox [
        geckodriver
        firefox
      ])
    } ${
      lib.optionalString withChromium "--add-flags '${firefoxArgs}'"
    } ${
      lib.optionalString withFirefox "--add-flags '${chromiumArgs}'"
    }
  '';

  meta = with lib; {
    description = "An open source tool that helps you monitor, analyze and optimize your website speed and performance";
    homepage = "https://sitespeed.io";
    license = licenses.mit;
    maintainers = with maintainers; [ misterio77 ];
    platforms = platforms.linux;
  };
}
