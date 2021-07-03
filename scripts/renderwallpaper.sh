#!/usr/bin/env bash
inkscape --export-type="png" ~/.nix-wallpaper.svg -w 2560 -h 1080 -o $HOME/.nix-wallpaper.png &> /dev/null
echo "$HOME/.nix-wallpaper.png" > $HOME/.bg
swaybg.sh &>/dev/null
