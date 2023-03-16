# Fetches current playing song lyrics from makeitpersonal.co
{ lib, writeShellApplication, curl, less, playerctl, gnused }: (writeShellApplication {
  name = "lyrics";
  runtimeInputs = [ playerctl curl less gnused ];

  text = /* bash */ ''
    # Exit the script if not playing
    playerctl -s status > /dev/null

    artist="$(playerctl metadata artist)"
    title="$(playerctl metadata title)"

    prefix="$artist - "
    title="''${title#"$prefix"}"

    suffix=" - $artist"
    title="''${title%"$suffix"}"

    # Cleanup featurings
    title="$(echo "$title" | sed -E 's/ ?\(fe?a?t\.?[^\)]*\)//')"
    artist="$(echo "$artist" | sed -E 's/ ?\(fe?a?t\.?[^\)]*\)//')"

    content="$(curl -f -s --get "https://makeitpersonal.co/lyrics" \
    --data-urlencode "artist=$artist" --data-urlencode "title=$title")"

    echo -e "$artist - $title\n$content" | less
  '';
}) // {
  meta = with lib; {
    description = "Lyrics fetcher script";
    license = licenses.mit;
    platforms = platforms.all;
    # The makeitpersonal API stopped working :(
    # TODO: look for alternatives
    broken = true;
  };
}
