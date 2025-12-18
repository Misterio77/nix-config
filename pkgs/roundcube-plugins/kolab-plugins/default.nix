{php, fetchgit, lessc, roundcube, ...}:
php.buildComposerProject2 (finalAttrs: {
  pname = "kolab-plugins";
  version = "2025-12-08";

  src = fetchgit {
    url = "https://git.kolab.org/diffusion/RPK";
    rev = "2bc08b75ca47fa385310d7c94397ce1e49469aa6";
    hash = "sha256-zJMkdeSg1NSn3U9SZb3TviwcPjx10vQpnbM+E61RAQ8=";
  };

  patches = [
    ./priorities.patch
    ./color-tweaks.patch
    ./darkmode-fixes.patch
  ];

  composerVendor = php.mkComposerVendor {
    inherit (finalAttrs) pname src version;
    # Rename composer file
    postUnpack = ''
      mv $sourceRoot/composer.json-dist $sourceRoot/composer.json
    '';
    composerLock = ./composer.lock;
    composerNoDev = true;
    composerNoPlugins = true;
    composerNoScripts = true;
    vendorHash = "sha256-pTXnO9wSqyAGVDNI5WU4UcLPuGXCQya9aITMp/V2sqg=";
    # Cleanup .git directories from git dependencies
    postInstall = ''
      rm -rf $out/vendor/**/*/.git
    '';
  };

  nativeBuildInputs = [lessc];
  postBuild = ''
    ln -s ${roundcube}/skins .
    lessc --relative-urls -x plugins/libkolab/skins/elastic/libkolab.less > plugins/libkolab/skins/elastic/libkolab.min.css
    unlink skins
  '';

  postInstall = ''
    ln -s $out/share/php/kolab-plugins/{plugins,vendor} $out/
  '';
})
