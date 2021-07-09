#!/usr/bin/env bash

template_path=~/.local/share/flavours/base16/templates/nix/templates/default.mustache

flavours list -l | while read slug; do
    scheme_path=$(flavours info $slug | head -1 | cut -d '@' -f2)
    flavours build $scheme_path $template_path > $slug.nix
done
