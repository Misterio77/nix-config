# Tally counter, also used as stopwatch
# tly <operation> [list-name]

{ lib, writeShellApplication, coreutils, gnugrep, bc }: (writeShellApplication {
  name = "tly";
  runtimeInputs = [ coreutils gnugrep bc ];
  text = builtins.readFile ./tly.sh;
}) // {
  meta = with lib; {
    licenses = licenses.mit;
    platforms = platforms.all;
  };
}
