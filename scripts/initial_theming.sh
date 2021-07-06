#!/usr/bin/env bash
mkdir -p $HOME/.config/nvim/colors
flavours current || flavours apply
setwallpaper -Q || setwallpaper -S && swaybg.sh
swaylock.sh --image $(cat $HOME/.bg)
