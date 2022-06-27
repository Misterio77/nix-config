# Pick a display to mirror using wl-mirror and slurp
{ writeShellApplication, wl-mirror, slurp }: writeShellApplication {
  name = "wl-mirror-pick";
  runtimeInputs = [ slurp wl-mirror ];

  text = /* bash */ ''
    set -euo pipefail
    output=$(slurp -f "%o" -o)
    wl-mirror "$output"
  '';
}
