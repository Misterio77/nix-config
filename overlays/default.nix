{ pkgs, lib, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      preferredplayer = let playerctl = "${prev.playerctl}/bin/playerctl";
      in prev.writeShellScriptBin "preferredplayer" ''
        if [[ -z "$1" ]]; then
            players=$(${playerctl} --list-all 2>/dev/null | \
            grep "$(cat $XDG_RUNTIME_DIR/currentplayer 2> /dev/null || echo '.*')") && \
            echo "$players" | head -1
        else
            echo "$1" > $XDG_RUNTIME_DIR/currentplayer
        fi
      '';
    })
    (final: prev: {
      minicava = let cava = "${prev.cava}/bin/cava";
      in prev.writeShellScriptBin "minicava" ''
        dict="s/;//g;s/0/▁/g;s/1/▂/g;s/2/▃/g;s/3/▄/g;s/4/▅/g;s/5/▆/g;s/6/▇/g;s/7/█/g;"

        config="
        [general]
        bars=7
        [output]
        method=raw
        data_format=ascii
        ascii_max_range=7
        "

        ${cava} -p <(echo "$config") | sed -u $dict
      '';
    })
    # A zenity wrapper for using with SUDO_ASKPASS
    # TODO: move to a nixpkg-like file
    (final: prev: {
      zenity-askpass = let zenity = "${prev.gnome.zenity}/bin/zenity";
      in prev.writeShellScriptBin "zenity-askpass" ''
        ${zenity} --password --timeout 10
      '';
    })
    # Setscheme graphical wrapper, using wofi and zenity
    # TODO: move to a nixpkg-like file
    (final: prev: {
      setscheme-wofi = let
        zenity-askpass = "${prev.zenity-askpass}/bin/zenity-askpass";
        zenity = "${prev.gnome.zenity}/bin/zenity";
        wofi = "${pkgs.wofi}/bin/wofi";
        setscheme = "${pkgs.setscheme}/bin/setscheme";
      in prev.writeShellScriptBin "setscheme-wofi" ''
        set -o pipefail
        chosen=$(${setscheme} -L | ${wofi} -S dmenu) && \
        SUDO_ASKPASS="${zenity-askpass}" ${setscheme} -A $chosen --show-trace --verbose 2>&1 | \
        stdbuf -oL -eL awk '/^ / { print int(+$2) ; next } $0 { print "# " $0 }' | \
        ${zenity} --progress --pulsate --auto-close --auto-kill --title "Change color scheme"
      '';
    })
    (final: prev: {
      pass-wofi = let
        wofi = "${pkgs.wofi}/bin/wofi -i";
        jq = "${pkgs.jq}/bin/jq";
        notify-send = "${pkgs.libnotify}/bin/notify-send";
      in prev.writeShellScriptBin "pass-wofi" ''
        cd ~/.local/share/password-store
        focused="$(swaymsg -t get_tree | ${jq} -r '.. | (.nodes? // empty)[] | select(.focused==true)')"
        app_id=$(${jq} -r '.app_id' <<< "$focused")
        class=$(${jq} -r '.window_properties.class' <<< "$focused")

        if [[ "$app_id" == "org.qutebrowser.qutebrowser" ]]; then
            qutebrowser :yank
            query=$(wl-paste | cut -d '/' -f3 | sed s/"www."//)
        elif [[ "$class" == "Spotify" ]]; then
            query="spotify.com"
        elif [[ "$class" == "discord" ]]; then
            query="discord.com"
        fi

        selected=$(find -L . -not -path '*\/.*' -path "*.gpg" -type f -printf '%P\n' | \
          sed 's/.gpg$//g' | \
          ${wofi} -S dmenu -Q "$query") || exit 2 

        username=$(echo "$selected" | cut -d '/' -f2)
        url=$(echo "$selected" | cut -d '/' -f1)

        fields="Password
        Username
        OTP
        URL"

        field=$(printf "$fields" | ${wofi} -S dmenu) || field="Password"

        case "$field" in
            "Password")
                value="$(pass "$selected" | head -n 1)" && [ -n "$value" ] || \
                    { ${notify-send} "Error" "No password for $selected" -i error -t 6000; exit 3; }
                ;;
            "Username")
                value="$username"
                ;;
            "URL")
                value="$url"
                ;;
            "OTP")
                value="$(pass otp "$selected")" || \
                    { ${notify-send} "Error" "No OTP for $selected" -i error -t 6000; exit 3; }
                ;;
            *)
                exit 4
        esac

        wl-copy "$value"
        ${notify-send} "Copied $field:" "$value" -i edit-copy -t 4000
      '';
    })
    # Script for changing color scheme
    # TODO: move to a nixpkg-like file
    (final: prev: {
      setscheme =
        prev.stdenv.mkDerivation {
          name = "setscheme";
          version = "1.0";
          src = prev.writeShellScriptBin "setscheme" ''
            if [ "$1" == "-A" ]; then
              sudo="sudo -A"
              shift
            else
              sudo="sudo"
            fi

            if [ "$1" == "-L" ]; then
              nix eval --raw --impure --expr 'builtins.concatStringsSep "\n" (builtins.attrNames (import /dotfiles/colors.nix))' 2> /dev/null
              exit 0
            elif [ "$1" == "-R" ]; then
              scheme=$(setscheme -L | ${prev.coreutils}/bin/shuf -n 1)
              echo $scheme
            else
              scheme=$1
            fi

            echo "\"$scheme\"" > /dotfiles/users/$USER/home/current-scheme.nix && \
            $sudo nixos-rebuild switch --flake /dotfiles ''${@:2}
          '';
          dontBuild = true;
          dontConfigure = true;
          nativeBuildInputs = [ prev.installShellFiles ];
          installPhase = ''
            install -Dm 0755 $src/bin/setscheme $out/bin/setscheme
            installShellCompletion --cmd setscheme \
              --fish <(echo 'complete -c setscheme -d "Which scheme to set" -r -f -a "(setscheme -L)"')
          '';
        };
    })
    # Swayfader
    # TODO: move to a nixpkg-like file
    (final: prev: {
      swayfader = prev.stdenv.mkDerivation {
        name = "swayfader";
        src = prev.fetchFromGitHub {
          owner = "Misterio77";
          repo = "swayfader";
          rev = "2be57f2e0685e52d1141c57fb62efebed6e276b3";
          sha256 = "sha256-foMu5Qxx4PD5YI67TuEe+sydP+pERUjB3MyoGOhHrjw=";
        };
        buildInputs = [ (prev.python3.withPackages (ps: [ ps.i3ipc ])) ];
        installPhase = "install -Dm 0755 $src/swayfader.py $out/bin/swayfader";
      };
    })
    (final: prev: {
      wshowkeys = prev.stdenv.mkDerivation {
        name = "wshowkeys";
        nativeBuildInputs = with prev; [ meson pkg-config wayland ninja ];
        buildInputs = with prev; [ cairo libinput pango wayland-protocols libxkbcommon ];
        src = prev.fetchFromGitHub {
          owner = "ammgws";
          repo = "wshowkeys";
          rev = "e8bfc78f08ebdd1316daae59ecc77e62bba68b2b";
          sha256 = "sha256-/HvNCQWsXOJZeCxHWmsLlbBDhBzF7XP/SPLdDiWMDC4=";
        };
      };
    })
    # My RGBDaemon
    # TODO: move to a nixpkg-like file
    (final: prev: {
      rgbdaemon = prev.stdenv.mkDerivation {
        name = "rgbdaemon";
        version = "0.1";
        src = prev.fetchFromGitHub {
          owner = "Misterio77";
          repo = "rgbdaemon";
          rev = "a7bf098a6dea1d280158627b887a0349fb9ad9c9";
          sha256 = "sha256-tH6ykZ9nO2GkSyxtJOdeekL887CsGmqJR9cYM7iR/eQ=";
        };
        dontBuild = true;
        dontConfigure = true;
        installPhase = ''
          install -Dm 0755 $src/rgbdaemon.sh $out/bin/rgbdaemon
        '';
      };
    })
    # Don't launch discord when using discocss
    (final: prev: {
      discocss = prev.discocss.overrideAttrs (oldAttrs: rec {
        patches = (oldAttrs.patches or [ ]) ++ [ ./discocss-no-launch.patch ];
      });
    })
    # Spawn terminal with xdg-open, from https://gitlab.freedesktop.org/xdg/xdg-utils/-/issues/84
    # Rebuilds a lot of stuff, sigh
    (final: prev: {
      xdg-utils = prev.xdg-utils.overrideAttrs (oldAttrs: rec {
        patches = (oldAttrs.patches or [ ]) ++ [ ./xdg-open-terminal.patch ];
      });
    })
    # Fixes https://todo.sr.ht/~scoopta/wofi/174
    (final: prev: {
      wofi = prev.wofi.overrideAttrs (oldAttrs: rec {
        patches = (oldAttrs.patches or [ ]) ++ [ ./wofi-run-shell.patch ];
      });
    })
    # Add suggestion for nix shell instead of nix-env
    (final: prev: {
      nix-index = prev.nix-index.overrideAttrs (oldAttrs: rec {
        patches = (oldAttrs.patches or [ ])
          ++ [ ./nix-index-new-command.patch ];
      });
    })
    # Link kitty to xterm (to fix crappy drun behaviour)
    (final: prev: {
      kitty = prev.kitty.overrideAttrs (oldAttrs: rec {
        postInstall = (oldAttrs.postInstall or " ") + ''
          ln -s $out/bin/kitty $out/bin/xterm
        '';
      });
    })
    (final: prev: {
      openrgb = prev.openrgb.overrideAttrs (oldAttrs: rec {
        buildInputs = (oldAttrs.buildInputs or [  ]) ++ [ prev.mbedtls ];
        version = "master";
        src = prev.fetchFromGitLab {
          owner = "CalcProgrammer1";
          repo = "OpenRGB";
          rev = "e4692cb5625fbc9634742d7043283f8bffa21bce";
          sha256 = "sha256-+t3TfeqMvmj5T3GpbbCZ5toqJYZpRkvX4/TBN76KwkU=";
        };
      });
    })
  ];
}
