# Fetches current playing song lyrics from makeitpersonal.co
{ writeShellApplication, curl, less, playerctl  }: writeShellApplication {
  name = "lyrics";
  runtimeInputs = [ playerctl curl less ];

  text = /* bash */ ''
    set -euo pipefail

    # Exit the script if not playing
    playerctl -s status > /dev/null

    artist="$(playerctl metadata artist)"
    title="$(playerctl metadata title)"

    content="$(curl -f -s --get "https://makeitpersonal.co/lyrics" \
    --data-urlencode "artist=$artist" --data-urlencode "title=$title")"

    echo -e "$artist - $title\n$content" | less
  '';
}
