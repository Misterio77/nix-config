#!/usr/bin/env bash
# Tally counter that also serves as stopwatch

now="$(date --rfc-3339="ns")"

XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
TLY_DIR="${TLY_DATA_DIR:-$XDG_DATA_HOME/tly}"
TLY_MAX_FILES="${TLY_MAX_FILES:-30}"

operation="${1:-}"
list="${2:-}"

if [ -z "${operation:-}" ]; then
    echo "No operation specified" >&2
    exit 1
fi

if [ -z "${list:-}" ]; then
    list="default"
fi
list_file="${TLY_DIR}/$list"

mkdir -p "$TLY_DIR"
touch "$list_file"

case "$operation" in
    # Add a timestamp
    a | add | ap | append)
        echo "$now" >> "$list_file"
        ;;
    # Add a comment
    c | comment)
        read -rp 'comment: ' comment
        if [ -z "${comment:-}" ]; then
            echo "Empty comment, skipping." >&2
            exit 2
        fi
        echo "# $comment" >> "$list_file"
        ;;
    # Remove last line
    u | undo)
        tmp="$(mktemp)"
        mv "$list_file" "$tmp"
        head -n -1 "$tmp" > "$list_file"
        rm "$tmp"
        ;;
    # Rotate the file
    r | reset)
        for suff in $(seq "$TLY_MAX_FILES" -1 1); do
            if [ -s "$list_file.${suff}" ]; then
                ((nxt = suff + 1))
                mv -f "$list_file.${suff}" "$list_file.${nxt}"
            fi
        done
        if [ -s "$list_file" ] ; then
            mv -f "$list_file" "$list_file.1"
        fi
        ;;

    # Get number of entries
    n | number)
        grep -cv "^#" "$list_file"
        ;;
    # Get list of entries
    l | list | s | show)
        cat "$list_file"
        ;;
    # Get time since last entry
    t | time)
        if [ -s "$list_file" ] ; then
            last="$(grep -v "^#" "$list_file" | tail -1)"
            diff="$(echo "$(date +%s.%N) - $(date +%s.%N -d "$last")" | bc -l)"
            printf "%.2fs\n" "$diff"
        else
            echo "0s"
        fi
        ;;
esac
