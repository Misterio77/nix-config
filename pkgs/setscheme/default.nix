{ lib, stdenv, writeShellScriptBin, installShellFiles, coreutils }:

with lib;

stdenv.mkDerivation {
  name = "setscheme";
  version = "1.0";
  src = writeShellScriptBin "setscheme" ''
    if [ "$1" == "-L" ]; then
      nix eval --raw nix-colors#colorSchemes --apply 's: builtins.concatStringsSep "\n" (builtins.attrNames s)' 2> /dev/null
      exit 0
    elif [ "$1" == "-R" ]; then
      scheme=$(setscheme -L | ${coreutils}/bin/shuf -n 1)
      echo $scheme
      exit 0
    elif [ "$1" == "generate" ]; then
      scheme="null"
      if [ -z "$2" ]; then
        mode="\"dark\""
      else
        mode="\"$2\""
        shift 1
      fi
    else
      scheme="\"$1\""
      mode="null"
    fi

    sed -i "s/currentScheme\.$HOSTNAME = .*;/currentScheme\.$HOSTNAME = $scheme;/" /dotfiles/users/$USER/rice.nix && \
    sed -i "s/currentMode = .*;/currentMode = $mode;/" /dotfiles/users/$USER/rice.nix && \
    home-manager switch --flake /dotfiles ''${@:2}
  '';
  dontBuild = true;
  dontConfigure = true;
  nativeBuildInputs = [ installShellFiles ];
  installPhase = ''
    install -Dm 0755 $src/bin/setscheme $out/bin/setscheme
    installShellCompletion --cmd setscheme \
      --fish <(echo 'complete -c setscheme -d "Which scheme to set" -r -f -a "(setscheme -L)"')
  '';

  meta = {
    description = "Script for setting colorscheme on my hm setup";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = with maintainers; [ misterio77 ];
  };
}

