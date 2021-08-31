{ pkgs, lib, ... }:

{
  nixpkgs.overlays = [

    (final: prev: {
      preferredplayer = let playerctl = "${prev.playerctl}/bin/playerctl";
      in prev.writeShellScriptBin "preferredplayer" ''
        if [[ -z "$1" ]]; then
            players=$(${playerctl} --list-all | \
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
    (final: prev: {
      zenity-askpass = let zenity = "${prev.gnome.zenity}/bin/zenity";
      in prev.writeShellScriptBin "zenity-askpass" ''
        ${zenity} --password --timeout 10
      '';
    })
    (final: prev: {
      setscheme-fzf = let
        zenity = "${prev.gnome.zenity}/bin/zenity";
        fzf = "${pkgs.alacritty-fzf}/bin/alacritty-fzf";
        setscheme = "${pkgs.setscheme}/bin/setscheme";
      in prev.writeShellScriptBin "setscheme-fzf" ''
        set -o pipefail
        chosen=$(${setscheme} -L | ${fzf}) && \
        ${setscheme} -A $chosen --show-trace --verbose 2>&1 | \
        stdbuf -oL -eL awk '/^ / { print int(+$2) ; next } $0 { print "# " $0 }' | \
        ${zenity} --progress --pulsate --auto-close --auto-kill --title "Change color scheme"
      '';
    })
    (final: prev: {
      setscheme =
        let zenity-askpass = "${prev.zenity-askpass}/bin/zenity-askpass";
        in prev.stdenv.mkDerivation {
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
            SUDO_ASKPASS="${zenity-askpass}" $sudo nixos-rebuild switch --flake /dotfiles ''${@:2}
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
    # Runs fzf inside a (usually floating) alacritty term
    (final: prev: {
      alacritty-fzf = let
        fzf = "${prev.fzf}/bin/fzf";
        alacritty = "${prev.alacritty}/bin/alacritty";
      in prev.writeShellScriptBin "alacritty-fzf" ''
        directory="$XDG_RUNTIME_DIR/alacritty-fzf"
        mkdir -p "$directory"

        tee > "$directory/input"

        cat <<'EOF' > "$directory/inner"
        #!/usr/bin/env bash
        sleep 0.1
        directory="$XDG_RUNTIME_DIR/alacritty-fzf"
        output=$(cat "$directory/input" | ${fzf} "$@")
        echo $? > "$directory/exitcode"
        echo "$output" > "$directory/output"
        EOF

        chmod +x "$directory/inner"

        ${alacritty} -t "Selector" --class AlacrittyFloatingSelector -e "$directory/inner" "$@"

        cat "$directory/output"
        exitcode="$(cat "$directory/exitcode")"
        #rm "$directory"/* &> /dev/null
        exit "$exitcode"
      '';
    })
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
      rgbdaemon = prev.stdenv.mkDerivation {
        name = "rgbdaemon";
        src = prev.fetchFromGitHub {
          owner = "Misterio77";
          repo = "rgbdaemon";
          rev = "83759ac45890049535b6b432f669beec19973d01";
          sha256 = "sha256-susdY8mK0zjtFb68x9jNZlwGbHPM2EPXZ+EVhaYPxjc=";
        };
        propagatedBuildInputs = with prev; [ pastel makeWrapper ];
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

    # Overrides 

    (final: prev: {
      alacritty = prev.alacritty.overrideAttrs (oldAttrs: rec {
        # TODO: Remove when https://github.com/alacritty/alacritty/pull/5313 is merged
        src = prev.fetchFromGitHub {
          owner = "ncfavier";
          repo = "alacritty";
          rev = "5f392c2cb516a5ea198ebb48754c7c42157d21b3";
          sha256 = "sha256-szPB8A8CGqU5Sf7evPOP/2xgWN5IFal4z95Yt44bNsM=";
        };
        cargoDeps = oldAttrs.cargoDeps.overrideAttrs (_: {
          inherit src;
          outputHash = "sha256-jCNkdgSzoiOW+jh/q3jR9SsiVa/MC5iz6nXgXOqQhdc=";
        });
        postInstall = (oldAttrs.postInstall or " ") + ''
          ln -s $out/bin/alacritty $out/bin/xterm
        '';
      });
    })
    (final: prev: {
      nodePackages = prev.nodePackages // {
        aws-azure-login = prev.nodePackages.aws-azure-login.overrideAttrs
          (oldAttrs: {
            version = "3.5.0";
            src = prev.fetchFromGitHub {
              owner = "misterio77";
              repo = "aws-azure-login";
              rev = "23206f5a70b8ef4036dab76c7144f709e944d719";
              sha256 = "sha256-JQct1z3Vg75uzpa9t6WLfSRLj/fueDJt5kSAm2K4q10=";
            };
            bypassCache = false;
          });
      };
    })
  ];
}
