# Fetches current playing song lyrics from makeitpersonal.co
{ writeShellApplication, curl, less, playerctl  }: writeShellApplication {
  name = "lyrics";
  runtimeInputs = [ playerctl curl less ];

  text = /* bash */ ''
    # Exit the script if not playing
    playerctl -s status > /dev/null

    artist="$(playerctl metadata artist)"
    title="$(playerctl metadata title)"

    prefix="$artist - "
    title="''${title#"$prefix"}"

    suffix=" - $artist"
    title="''${title%"$suffix"}"

    content="$(curl -f -s --get "https://makeitpersonal.co/lyrics" \
    --data-urlencode "artist=$artist" --data-urlencode "title=$title")"

    echo -e "$artist - $title\n$content" | less
  '';
}
