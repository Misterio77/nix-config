{ pkgs, lib, stdenv, writeShellScriptBin, installShellFiles, coreutils }:

with lib;

stdenv.mkDerivation {
  name = "setwallpaper";
  version = "1.0";
  src = writeShellScriptBin "setwallpaper" ''
    if [ "$1" == "-L" ]; then
      nix eval --raw self#wallpapers --apply 's: builtins.concatStringsSep "\n" (builtins.attrNames s)' 2> /dev/null
      exit 0
    elif [ "$1" == "-R" ]; then
      wallpaper=$(setwallpaper -L | ${coreutils}/bin/shuf -n 1)
      echo $wallpaper
      exit 0
    elif [ "$1" == "generate" ]; then
      wallpaper="null"
    else
      wallpaper="\"$1\""
    fi

    sed -i "s/currentWallpaper\.$HOSTNAME = .*;/currentWallpaper\.$HOSTNAME = $wallpaper;/" /dotfiles/users/$USER/rice.nix && \
    home-manager -v switch --flake /dotfiles ''${@:2}
  '';
  dontBuild = true;
  dontConfigure = true;
  nativeBuildInputs = [ installShellFiles ];
  installPhase = ''
    install -Dm 0755 $src/bin/setwallpaper $out/bin/setwallpaper
    installShellCompletion --cmd setwallpaper \
      --fish <(echo 'complete -c setwallpaper -d "Which wallpaper to set" -r -f -a "(setwallpaper -L)"')
  '';

  meta = {
    description = "Script for setting wallpapers on my hm setup";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = with maintainers; [ misterio77 ];
  };
}

