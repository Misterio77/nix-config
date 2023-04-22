{ lib
, fetchFromGitHub
, buildNpmPackage
, makeWrapper

, python3
, python3Packages
, nodejs-18_x
, nodejs ? nodejs-18_x

, ffmpeg-full
, imagemagick
, xorg
, chromium
, chromedriver

, withChromium ? true
}:
let
  # https://github.com/NixOS/nixpkgs/pull/227681
  pyssim = python3Packages.pyssim.overrideAttrs (_: rec {
    version = "0.6";
    src = fetchFromGitHub {
      owner = "jterrace";
      repo = "pyssim";
      rev = "v${version}";
      sha256 = "sha256-VvxQTvDTDms6Ccyclbf9P0HEQksl5atPPzHuH8yXTmc";
    };
  });
in
buildNpmPackage.override { inherit nodejs; } rec {
  pname = "sitespeedio";
  version = "27.3.0";

  src = fetchFromGitHub {
    owner = pname;
    repo = "sitespeed.io";
    rev = "v${version}";
    sha256 = "sha256-7CnoKmyoNIO+ovPsChbuZiyD7n2llMSZAgjMSb867H8=";
  };

  npmDepsHash = "sha256-tMgHDDlF6182OnBrwQYZLQXRZfVAEX05MGGKrXOYosk=";

  nativeBuildInputs = [ makeWrapper ];

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
    mkdir -p $out
  '';

  postFixup = ''
    wrapProgram $out/bin/sitespeedio \
      --set PATH ${lib.makeBinPath ([
        (python3.withPackages (p: [p.numpy p.opencv4 pyssim]))
        ffmpeg-full
        imagemagick
        xorg.xorgserver
      ] ++ lib.optionals withChromium [
        chromium
        chromedriver
      ])}
  '';

  meta = with lib; {
    description = "An open source tool that helps you monitor, analyze and optimize your website speed and performance";
    homepage = "https://sitespeed.io";
    license = licenses.mit;
    maintainers = with maintainers; [ misterio77 ];
    platforms = platforms.linux;
    broken = true;
  };
}
