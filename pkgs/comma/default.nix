{ lib, stdenv
, writeShellScriptBin
, nix-index, gnugrep
}:

with lib;

stdenv.mkDerivation {
  name = "comma";
  version = "1.0";
  src = writeShellScriptBin "comma" ''
    if [ -z "$1" ]; then
      echo "You must specify a command" > /dev/stderr
      exit 1
    else
      command="$1"
      shift
    fi

    packages=$(${nix-index}/bin/nix-locate -r "bin/$command(-wrapped)?$") || { >&2 echo "No package found"; exit 2;}

    package_line=$(${gnugrep}/bin/grep -G "^coreutils.out " <<< "$packages" || \
    ${gnugrep}/bin/grep -G "^''${command}-wrapper.out " <<< "$packages" || \
    ${gnugrep}/bin/grep -G "^''${command}.out " <<< "$packages" || head -1 <<< "$packages")

    package=$(echo "$package_line" | cut -d ' ' -f1)

    >&2 printf "\033[0;32mUsing package\033[0m: ''${package}\n"

    nix shell nixpkgs#"$package" --command "$command" $@
  '';
  dontBuild = true;
  dontConfigure = true;

  installPhase = "install -Dm 0755 $src/bin/comma $out/bin/,";

  meta = {
    description = "Automatically shell into whatever package provides a command you asked for";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = with maintainers; [ misterio77 ];
  };
}

