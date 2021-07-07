#!/usr/bin/env bash
old=$(pgrep -f swayfader)
swayfader & \
if ! [ -z "$old" ]; then
    kill $old > /dev/null
fi
