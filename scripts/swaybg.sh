#!/usr/bin/env bash
old=$(pgrep -f "swaybg -i")
swaybg -i $(cat ~/.bg) -m fill & \
sleep 0.4
if ! [ -z "$old" ]; then
    kill $old > /dev/null
fi
