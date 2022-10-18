{ lib, callPackage, fetchFromGitHub }:

let
  composerEnv = callPackage ./composer-env.nix { };
  composerPackages = callPackage ./php-packages.nix { inherit composerEnv; };
in
composerEnv.buildPackage {
  inherit (composerPackages) packages devPackages;
  name = "phpactor-phpactor";
  src = fetchFromGitHub {
    owner = "phpactor";
    repo = "phpactor";
    rev = "e7d404c2c6fbe606e5a6374b8e3d0c0d0430487f";
    sha256 = "sha256-S5/Itbd4YFZFJ1xDVREGYsslGNQY+9p+w4v/3hz4p+c=";
  };
  executable = true;
  symlinkDependencies = false;
  noDev = true;
  composerExtraArgs = "--no-scripts";
  meta = with lib; {
    license = licenses.mit;
    platforms = platforms.all;
  };
}
