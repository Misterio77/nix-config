{ writeShellScriptBin, perl, gnugrep, findutils }:
writeShellScriptBin "nix-inspect" ''
  read -ra EXCLUDED <<< "$@"
  EXCLUDED+=(''${NIX_INSPECT_EXCLUDE[@]:-})

  IFS=":" read -ra PATHS <<< "$PATH"

  read -ra PROGRAMS <<< \
    "$(printf "%s\n" "''${PATHS[@]}" | ${gnugrep}/bin/grep '/nix/store' | ${gnugrep}/bin/grep -v '\-man' | ${perl}/bin/perl -pe 's:^/nix/store/\w{32}-([^/]*)/bin$:\1:' | ${findutils}/bin/xargs)"

  for to_remove in "''${EXCLUDED[@]}"; do
      to_remove_full="$(printf "%s\n" "''${PROGRAMS[@]}" | grep "$to_remove" )"
      PROGRAMS=("''${PROGRAMS[@]/$to_remove_full}")
  done

  read -ra PROGRAMS <<< "''${PROGRAMS[@]}"
  echo "''${PROGRAMS[@]}"
''
