# Tally counter, also used as stopwatch
# tly <operation> [list-name]

{ lib, writeShellApplication }: (writeShellApplication {
  name = "tly";
  text = builtins.readFile ./tly.sh;
}) // {
  meta = with lib; {
    licenses = licenses.mit;
    platforms = platforms.all;
  };
}
