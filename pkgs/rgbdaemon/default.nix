{ lib
, writeShellApplication
, findutils
, gnugrep
, procps
, gawk
, coreutils
, openrgb
, pastel
, pulseaudio
, playerctl
}:

with lib;

(writeShellApplication {
  name = "rgbdaemon";
  runtimeInputs = [
    findutils
    gnugrep
    procps
    gawk
    coreutils
    openrgb
    pastel
    pulseaudio
    playerctl
  ];

  checkPhase = "";
  text = /* bash */ ''
    set +o nounset

    base_colors() {
      if [ ! -p "$KEYBOARD_DEVICE" ] || [ ! -p "$MOUSE_DEVICE" ]; then
        echo "Keyboard or mouse device not found, exiting..."
        exit 1
      fi

      echo "rgb $1" > $KEYBOARD_DEVICE
      echo "rgb $1" > $MOUSE_DEVICE
      echo "rgb $KEYBOARD_HIGHLIGHTED:$2" > $KEYBOARD_DEVICE
      echo "rgb $MOUSE_HIGHLIGHTED:$2" > $MOUSE_DEVICE
    }

    setcolor() {
      if [ ! -p "$3" ]; then
        echo "Device $3 not found, exiting..."
        exit 1
      fi
      echo "rgb $1:$2" > $3
    }

    daemon_mute() {
      audio_input=$(pactl info | grep "Default Source" | cut -f3 -d " ")
      audio_output=$(pactl info | grep "Default Sink" | cut -f3 -d " ")
      input_muted=$(pactl list sources | grep -A 10 "''${audio_input}" | grep "Mute" | cut -d ":" -f2 | xargs)
      output_muted=$(pactl list sinks | grep -A 10 "''${audio_output}" | grep "Mute" | cut -d ":" -f2 | xargs)

      if [[ "$output_muted" == "yes" ]] && [[ "$input_muted" == "yes" ]]; then
        setcolor "mute" "$4" $KEYBOARD_DEVICE
      elif [[ "$input_muted" == "yes" ]]; then
        setcolor "mute" $3 $KEYBOARD_DEVICE
      elif [[ "$output_muted" == "yes" ]]; then
        setcolor "mute" $2 $KEYBOARD_DEVICE
      else
        setcolor "mute" $1 $KEYBOARD_DEVICE
      fi
    }

    daemon_player() {
      status=$(playerctl status 2>/dev/null | head -n 1)

      if [[ $status == "Playing" ]]; then
        setcolor "play" $1 $KEYBOARD_DEVICE
      elif [[ $status == "Paused" ]]; then
        setcolor "play" $2 $KEYBOARD_DEVICE
      else
        setcolor "play" $3 $KEYBOARD_DEVICE
      fi
    }

    daemon_lock() {
      if pgrep -x swaylock > /dev/null; then
        setcolor "lock" $1 $KEYBOARD_DEVICE
      else
        setcolor "lock" $2 $KEYBOARD_DEVICE
      fi
    }

    bindings() {
      echo "bind profswitch:f13" > $KEYBOARD_DEVICE
      echo "bind lock:f14" > $KEYBOARD_DEVICE
      echo "bind light:f15" > $KEYBOARD_DEVICE
      echo "bind thumb1:1" > $MOUSE_DEVICE
      echo "bind thumb2:2" > $MOUSE_DEVICE
      echo "bind thumb3:3" > $MOUSE_DEVICE
      echo "bind thumb4:4" > $MOUSE_DEVICE
      echo "bind thumb5:5" > $MOUSE_DEVICE
      echo "bind thumb6:6" > $MOUSE_DEVICE
      echo "bind thumb7:7" > $MOUSE_DEVICE
      echo "bind thumb8:8" > $MOUSE_DEVICE
      echo "bind thumb9:9" > $MOUSE_DEVICE
      echo "bind thumb10:0" > $MOUSE_DEVICE
      echo "bind thumb11:minus" > $MOUSE_DEVICE
      echo "bind thumb12:equal" > $MOUSE_DEVICE
      echo "bind dpiup:mouse4" > $MOUSE_DEVICE
      echo "bind dpidn:mouse5" > $MOUSE_DEVICE
    }

    startup() {
      if [ -n "''${rgb_pid}" ]; then
        kill "''${rgb_pid}"
      fi

      source ''${XDG_CONFIG_HOME:-$HOME/.config}/rgbdaemon.conf

      export DAEMON_INTERVAL=''${DAEMON_INTERVAL:-0.8}
      export KEYBOARD_DEVICE=''${KEYBOARD_DEVICE:-/dev/input/ckb1/cmd}
      export MOUSE_DEVICE=''${MOUSE_DEVICE:-/dev/input/ckb2/cmd}
      export KEYBOARD_HIGHLIGHTED=''${KEYBOARD_HIGHLIGHTED}
      export MOUSE_HIGHLIGHTED=''${MOUSE_HIGHLIGHTED}
      export ENABLE_SWAY_WORKSPACES=''${ENABLE_SWAY_WORKSPACES}
      export ENABLE_SWAY_LOCK=''${ENABLE_SWAY_LOCK}
      export ENABLE_MUTE=''${ENABLE_MUTE}
      export ENABLE_TTY=''${ENABLE_TTY}
      export ENABLE_PLAYER=''${ENABLE_PLAYER}

      export color_primary=$(pastel mix $COLOR_BACKGROUND --fraction 0.7 $COLOR_FOREGROUND | pastel darken 0.1 | pastel saturate 0.5 | pastel format hex | cut -d '#' -f2)
      export color_secondary=$(pastel darken 0.1 $COLOR_SECONDARY | pastel saturate 0.8 | pastel format hex | cut -d '#' -f2)
      export color_tertiary=$(pastel saturate 0.1 $COLOR_TERTIARY | pastel format hex | cut -d '#' -f2)
      export color_quaternary=$(pastel lighten 0.1 $COLOR_QUATERNARY | pastel format hex | cut -d '#' -f2)
      echo "COLORS: $color_primary | $color_secondary | $color_tertiary | $color_quaternary"

      # Activate devices
      echo active > $KEYBOARD_DEVICE || exit -1
      echo active > $MOUSE_DEVICE || exit -1

      echo "dpi 1:$MOUSE_DPI dpisel 1" > $MOUSE_DEVICE

      # Set up bindings
      bindings

      base_colors $color_primary $color_secondary & \
      openrgb --client --color $color_primary --mode direct & \
      rgb_daemon & rgb_pid=$!

      wait
    }

    off() {
      echo "rgb 000000" > $MOUSE_DEVICE & \
      echo "rgb 000000" > $KEYBOARD_DEVICE
      openrgb --client --color "000000" --mode direct
      exit
    }

    rgb_daemon() {
      while sleep $DAEMON_INTERVAL; do
        # Activate devices
        echo active > $KEYBOARD_DEVICE || exit -1
        echo active > $MOUSE_DEVICE || exit -1

        [[ "$ENABLE_SWAY_LOCK" == 1 ]] && \
          daemon_lock $color_secondary $color_primary & \
        [[ "$ENABLE_MUTE" == 1 ]] && \
          daemon_mute "000000" $color_primary $color_tertiary $color_secondary & \
        [[ "$ENABLE_PLAYER" == 1 ]] && \
          daemon_player $color_secondary $color_tertiary $color_primary & \
      done
    }

    trap startup SIGHUP
    trap off SIGTERM

    startup
  '';
}) // {
  meta = with lib; {
    license = licenses.mit;
    platforms = platforms.all;
  };
}
