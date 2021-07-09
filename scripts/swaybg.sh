#!/usr/bin/env bash
old=$(pgrep -f "swaybg -i")
swaybg -i $(cat ~/.bg) -m fill & \
if ! [ -z "$old" ]; then
    sleep 0.2
    kill $old > /dev/null
fi
