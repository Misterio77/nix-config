# Sets the largest monitor as primary xwayland display, or select one with slurp
{ writeShellApplication, xrandr, slurp  }: writeShellApplication {
  name = "primary-xwayland";
  runtimeInputs = [ slurp xrandr ];

  text = /* bash */ ''
    set -euo pipefail

    if [ "$#" -ge 1 ] && [ "$1" == "largest" ]; then
      output=$(xrandr --listmonitors | tail -n +2 | awk '{printf "%s %s\n", $3, $4}' | sort | tail -1 | cut -d ' ' -f2)
    else
      selected=$(slurp -f "%wx%h+%x+%y" -o)
      output=$(xrandr | grep "$selected" | cut -d ' ' -f1)
    fi

    echo "Setting $output"
    xrandr --output "$output" --primary
  '';
}
