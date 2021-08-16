{ pkgs, lib, ... }:

{
  nixpkgs.overlays = [
    # A program that allows for quickly running packages from nixpkgs
    # Inspired by https://github.com/Shopify/comma, but for flakes
    # You can run a program whose name is the same as the package name using, for example:
    # , jq --version
    # Or specify the command using another comma, for example:
    # , glib,gsettings --version
    (final: prev: {
      comma = pkgs.stdenv.mkDerivation {
        name = "comma";
        src = pkgs.writeShellScriptBin "comma" ''
          package=$(echo "$1," | cut -d ',' -f1)
          command=$(echo "$1," | cut -d ',' -f2)

          if [ -z "$command" ]; then
            nix run nixpkgs#$package -- ''${@:2}
          else
            nix shell nixpkgs#$package -c $command ''${@:2}
          fi
        '';
        dontBuild = true;
        dontConfigure = true;
        installPhase = ''
          install -Dm 0755 $src/bin/comma "$out/bin/,"
        '';
      };
    })
    # A zenity wrapper for using with SUDO_ASKPASS
    (final: prev: {
      zenity-askpass = let
        zenity = "${pkgs.gnome.zenity}/bin/zenity";
      in pkgs.stdenv.mkDerivation {
        name = "zenity-askpass";
        src = pkgs.writeShellScriptBin "zenity-askpass" ''
          ${zenity} --password --timeout 10
        '';
        dontBuild = true;
        dontConfigure = true;
        installPhase = ''
          install -Dm 0755 $src/bin/zenity-askpass $out/bin/zenity-askpass
        '';
      };
    })
    (final: prev: {
      setscheme-fzf = let
        zenity = "${pkgs.gnome.zenity}/bin/zenity";
        fzf = "${pkgs.alacritty-fzf}/bin/alacritty-fzf";
        setscheme = "${pkgs.setscheme}/bin/setscheme";
      in pkgs.stdenv.mkDerivation {
        name = "setscheme-fzf";
        src = pkgs.writeShellScriptBin "setscheme-fzf" ''
          set -o pipefail
          chosen=$(nix eval --impure --raw --expr 'builtins.concatStringsSep "\n" (builtins.attrNames (import /dotfiles/colors.nix))' | ${fzf}) && \
          ${setscheme} -A $chosen --show-trace --verbose 2>&1 | \
          stdbuf -oL -eL awk '/^ / { print int(+$2) ; next } $0 { print "# " $0 }' | \
          ${zenity} --progress --pulsate --auto-close --auto-kill --title "Change color scheme"
        '';
        dontBuild = true;
        dontConfigure = true;
        installPhase = ''
          install -Dm 0755 $src/bin/setscheme-fzf $out/bin/setscheme-fzf
        '';
      };
    })
    (final: prev: {
      setscheme = let
        zenity-askpass = "${pkgs.zenity-askpass}/bin/zenity-askpass";
      in pkgs.stdenv.mkDerivation {
        name = "setscheme";
        src = pkgs.writeShellScriptBin "setscheme" ''
          if [ "$1" == "-A" ]; then
            sudo="sudo -A"
            shift
          else
            sudo="sudo"
          fi

          sed -i "/colorscheme = /c \ \ colorscheme = colors.$1;" /dotfiles/users/$USER/home/default.nix && \
          SUDO_ASKPASS="${zenity-askpass}" $sudo nixos-rebuild switch --flake /dotfiles ''${@:2}
        '';
        dontBuild = true;
        dontConfigure = true;
        installPhase = ''
          install -Dm 0755 $src/bin/setscheme $out/bin/setscheme
        '';
      };
    })
    # Runs fzf inside a (usually floating) alacritty term
    (final: prev: {
      alacritty-fzf = let
        fzf = "${pkgs.fzf}/bin/fzf";
        alacritty = "${pkgs.alacritty}/bin/alacritty";
      in pkgs.stdenv.mkDerivation {
        name = "alacritty-fzf";
        src = pkgs.writeShellScriptBin "alacritty-fzf" ''
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
        dontBuild = true;
        dontConfigure = true;
        installPhase = ''
          install -Dm 0755 $src/bin/alacritty-fzf $out/bin/alacritty-fzf
        '';
      };
    })
    (final: prev: {
      swayfader = pkgs.stdenv.mkDerivation {
        name = "swayfader";
        src = pkgs.fetchFromGitHub {
          owner = "Misterio77";
          repo = "swayfader";
          rev = "3f18eacb4b43ffd2d8c10a395a3e77bbb40ccee6";
          sha256 = "0x490g1g1vjrybnwna9z00r9i61d5sbrzq7qi7mdq6y94whwblla";
        };
        buildInputs = [ (pkgs.python3.withPackages (ps: [ ps.i3ipc ])) ];
        dontBuild = true;
        dontConfigure = true;
        installPhase = "install -Dm 0755 $src/swayfader.py $out/bin/swayfader";
      };
    })
    (final: prev: {
      rgbdaemon = prev.stdenv.mkDerivation {
        name = "rgbdaemon";
        src = pkgs.fetchFromGitHub {
          owner = "Misterio77";
          repo = "rgbdaemon";
          rev = "28d12fb0458cdeaeeb75c4e211f786190d4873a2";
          sha256 = "sha256-p1cwW33zRuZ4bHadGn6lzRLzuPyuBkcP/OYNsppNpZo=";
        };
        propagatedBuildInputs = with pkgs; [ pastel makeWrapper ];
        dontBuild = true;
        dontConfigure = true;
        installPhase = ''
          install -Dm 0755 $src/rgbdaemon.sh $out/bin/rgbdaemon
        '';
      };
    })
    # TODO: Remove when https://github.com/alacritty/alacritty/pull/5313 is merged
    (final: prev: {
      alacritty = prev.alacritty.overrideAttrs (oldAttrs: rec {
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
      });
    })
    # Fixes https://todo.sr.ht/~scoopta/wofi/174
    (final: prev: {
      wofi = prev.wofi.overrideAttrs (oldAttrs: rec {
        patches = (oldAttrs.patches or []) ++ [
          ./wofi-run-shell.patch
        ];
      });
    })
    # Add suggestion for nix shell instead of nix-env
    (final: prev: {
      nix-index = prev.nix-index.overrideAttrs (oldAttrs: rec {
        patches = (oldAttrs.patches or []) ++ [
          ./nix-index-new-command.patch
        ];
      });
    })
  ];
}
