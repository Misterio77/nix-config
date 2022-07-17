#!/usr/bin/env -S nix shell nixpkgs#httpie nixpkgs#jq --command bash

function fetch_image() {
    image=$1

    name=$(echo $image | cut -d '|' -f 1)
    ext=$(echo $image | cut -d '|' -f 2 | cut -d '/' -f 2)
    id=$(echo $image | cut -d '|' -f 3)
    sha256=$(nix-prefetch-url https://i.imgur.com/$id.$ext)

    echo "  {"
    echo "    name = \"$name\";"
    echo "    ext = \"$ext\";"
    echo "    id = \"$id\";"
    echo "    sha256 = \"$sha256\";"
    echo "  }"
}

album="bXDPRpV" # https://imgur.com/a/bXDPRpV
clientid="0c2b2b57cdbe5d8"

result=$(https api.imgur.com/3/album/$album Authorization:"Client-ID $clientid")
images=$(echo $result | jq -r '.data.images[] | "\(.description)|\(.type)|\(.id)"')


echo "["
while read -r image; do
    fetch_image $image
done <<< "$images"
wait
echo "]"
