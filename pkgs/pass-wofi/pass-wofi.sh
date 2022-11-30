cd "${PASSWORD_STORE_DIR:-$HOME/.password-store}"

if [ "$XDG_CURRENT_DESKTOP" == "Hyprland" ]; then
    class="$(hyprctl activewindow -j | jq -r '.class')"
elif [ "$XDG_CURRENT_DESKTOP" == "sway" ]; then
    focused="$(swaymsg -t get_tree | jq -r '.. | (.nodes? // empty)[] | select(.focused==true)')"
    class=$(jq -r '.window_properties.class' <<< "$focused")
fi

if [[ "$class" == "org.qutebrowser.qutebrowser" ]]; then
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

fields="Password
Username
OTP
URL"

field=$(printf "$fields" | wofi -S dmenu) || field="Password"

case "$field" in
    "Password")
        value="$(pass "$selected" | head -n 1)" && [ -n "$value" ] || \
            { notify-send "Error" "No password for $selected" -i error -t 6000; exit 3; }
        ;;
    "Username")
        value="$username"
        ;;
    "URL")
        value="$url"
        ;;
    "OTP")
        value="$(pass otp "$selected")" || \
            { notify-send "Error" "No OTP for $selected" -i error -t 6000; exit 3; }
        ;;
    *)
        exit 4
esac

wl-copy "$value"
notify-send "Copied $field:" "$value" -i edit-copy -t 4000
