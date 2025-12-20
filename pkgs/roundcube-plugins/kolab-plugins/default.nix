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
    strictDeps = true;
    vendorHash = "sha256-QYERch9v0glBK+rqvsh36s78YziVed07TsHz10N6zgs=";
    postInstall = ''
      # Cleanup .git directories from git dependencies
      rm -rf $out/vendor/**/*/.git
      # Make include_paths.php deterministic
      head -n 8 $out/vendor/composer/include_paths.php > include_paths.php
      tail -n +9 $out/vendor/composer/include_paths.php | head -n -1 | sort >> include_paths.php
      tail -n 1 $out/vendor/composer/include_paths.php >> include_paths.php
      mv include_paths.php $out/vendor/composer/include_paths.php
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
