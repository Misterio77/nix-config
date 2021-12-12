#!/usr/bin/env bash

PREVIEWER=${PREVIEWER:-imv}

watch_file() {
    while true; do
        inotifywait -e modify "$1" &> /dev/null
        plantuml "$1"
    done
}

shopt -s globstar
for file in src/**/*.uml; do
    plantuml "$file"
    "$PREVIEWER" "${file/.uml/.png}" &
    watch_file "$file" &
done

wait
