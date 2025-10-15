#!/usr/bin/env bash

contents="$(mktemp)"
trap 'rm -f "$contents"' EXIT
cat /dev/stdin > "$contents"

clip_text() {
  data="$(cat "$1")"
  lines="$(wc -l <<< "$data")"
  if [ "$lines" -gt 5 ]; then
    head -n 3 <<< "$data"
    echo "<i>[[ $((lines - 4)) more lines... ]]</i>"
    tail -n 1 <<< "$data"
  else
    echo "$data"
  fi
}
censor_text() {
  data="$(cat "$1")"
  prefix="${data:0:3}"
  suffix="${data:3}"
  echo "${prefix}${suffix//?/*}"
}
show_binary() {
  size="$(du -h "$1" | cut -f1)"
  metadata="$(file "$1" | cut -d : -f2- | cut -d , -f1,2)"
  echo "<i>[[ $size$metadata ]]</i>"
}

mimes="$(wl-paste -l)"

if [ "$CLIPBOARD_STATE" = "nil" ]; then
  exit 0
elif [[ "$mimes" =~ "text/plain" ]]; then
  if [ "$CLIPBOARD_STATE" = "sensitive" ] || [[ "$mimes" =~ "text/secret" ]]; then
    preview="$(censor_text "$contents")"
  else
    preview="$(clip_text "$contents")"
  fi
else
  preview="$(show_binary "$contents")"
fi

notify-send "Copied to Clipboard:" "$preview" -i edit-copy -t 2000
