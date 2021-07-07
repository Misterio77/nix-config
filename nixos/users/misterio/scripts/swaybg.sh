#!/usr/bin/env bash
old=$(pgrep -f "swaybg -i")
swaybg -i $(cat ~/.bg) -m fill & \
if ! [ -z "$old" ]; then
    kill $old > /dev/null
fi
