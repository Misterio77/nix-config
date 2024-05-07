cd "${PASSWORD_STORE_DIR:-$HOME/.password-store}"

if [ "$XDG_CURRENT_DESKTOP" == "Hyprland" ]; then
    class="$(hyprctl activewindow -j | jq -r '.class')"
elif [ "$XDG_CURRENT_DESKTOP" == "sway" ]; then
    focused="$(swaymsg -t get_tree | jq -r '.. | (.nodes? // empty)[] | select(.focused==true)')"
    class=$(jq -r '.window_properties.class' <<< "$focused")
fi

if [[ "$class" == "org.qutebrowser.qutebrowser" ]] || [[ "$class" == "qutebrowser" ]]; then
    qutebrowser :yank
    query=$(wl-paste | cut -d '/' -f3 | sed s/"www."//)
elif [[ "$class" == "discord" ]]; then
    query="discord.com"
elif [[ "$class" == "Steam" ]]; then
    query="steampowered.com"
fi

selected=$(find -L . -not -path '*\/.*' -path "*.gpg" -type f -printf '%P\n' | \
  sed 's/.gpg$//g' | \
  wofi -S dmenu -Q "$query") || exit 2

username=$(echo "$selected" | cut -d '/' -f2)
url=$(echo "$selected" | cut -d '/' -f1)

if [ -n "$1" ]; then
    field="$1"
    shift 1
else
    fields="Password
Username
OTP
URL
Fill"

    field=$(printf "$fields" | wofi -S dmenu) || field="password"
fi

case "${field,,}" in
    "password")
        value="$(pass "$selected" | head -n 1)" && [ -n "$value" ] || \
            { notify-send "Error" "No password for $selected" -i error -t 6000; exit 3; }
        ;;
    "username")
        value="$username"
        ;;
    "url")
        value="$url"
        ;;
    "otp")
        value="$(pass otp "$selected")" || \
            { notify-send "Error" "No OTP for $selected" -i error -t 6000; exit 3; }
        ;;
    "fill")
        password="$(pass "$selected" | head -n 1)" && [ -n "$password" ] || \
            { notify-send "Error" "No password for $selected" -i error -t 6000; exit 3; }
        wtype "$username"
        sleep 0.1
        wtype -k tab
        sleep 0.1
        wtype "$password"
        if otp="$(pass otp "$selected")" && [ -n "$otp" ]; then
            field="OTP"
            value="$otp"
        fi
        ;;
    *)
        exit 4
esac

if [ -n "$value" ]; then
    wl-copy "$value"
    notify-send "Copied $field:" "$value" -i edit-copy -t 4000
fi
