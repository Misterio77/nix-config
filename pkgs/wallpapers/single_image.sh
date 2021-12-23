#!/usr/bin/env nix-shell
#!nix-shell -i bash -p jq httpie

image="$(echo "$1" | rev | cut -d '/' -f1 | rev | cut -d '.' -f1)"
clientid="0c2b2b57cdbe5d8"

result=$(https api.imgur.com/3/image/$image Authorization:"Client-ID $clientid")
image=$(echo $result | jq -r '.data | "\(.description)|\(.type)|\(.id)"')

name=$(echo $image | cut -d '|' -f 1)
ext=$(echo $image | cut -d '|' -f 2 | cut -d '/' -f 2)
id=$(echo $image | cut -d '|' -f 3)
sha256=$(nix-prefetch-url https://i.imgur.com/$id.$ext)

echo "{"
echo "  name = \"$name\";"
echo "  ext = \"$ext\";"
echo "  id = \"$id\";"
echo "  sha256 = \"$sha256\";"
echo "}"
