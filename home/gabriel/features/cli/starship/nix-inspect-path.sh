IFS=" " read -ra excluded <<< "${NIX_INSPECT_EXCLUDE:-} perl gnugrep findutils"
IFS=":" read -ra paths <<< "${PATH:-}"

read -ra programs <<< \
    "$(printf "%s\n" "${paths[@]}" | grep '/nix/store' | grep -v -e '\-man' -e '\-terminfo' | perl -pe 's:^/nix/store/\w{32}-([^/]*)/bin$:\1:' | xargs)"

for to_remove in "${excluded[@]}"; do
  to_remove_full="$(printf "%s\n" "${programs[@]}" | grep "$to_remove" )"
  programs=("${programs[@]/$to_remove_full}")
done

echo "${programs[@]}"
