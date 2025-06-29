{
  inputs,
  lib,
  pkgs,
  config,
  outputs,
  ...
}: {
  imports =
    [
      inputs.impermanence.homeManagerModules.impermanence
      ../features/cli
      ../features/helix
    ]
    ++ (builtins.attrValues outputs.homeManagerModules);

  nix = {
    package = lib.mkDefault pkgs.nix;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
        "ca-derivations"
      ];
      warn-dirty = false;
    };
  };

  systemd.user.startServices = "sd-switch";

  programs = {
    home-manager.enable = true;
    git.enable = true;
  };

  home = {
    username = lib.mkDefault "gabriel";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
    stateVersion = lib.mkDefault "22.05";
    sessionPath = ["$HOME/.local/bin"];
    sessionVariables = {
      NH_FLAKE = "$HOME/Documents/NixConfig";
    };

    persistence = {
      "/persist".directories = [
        "Documents"
        "Downloads"
        "Pictures"
        "Videos"
        ".local/bin"
        ".local/share/nix" # trusted settings and repl history
      ];
    };
  };

  colorscheme.mode = lib.mkOverride 1499 "dark";
  specialisation = {
    dark.configuration.colorscheme.mode = lib.mkOverride 1498 "dark";
    light.configuration.colorscheme.mode = lib.mkOverride 1498 "light";
  };
  home.file = {
    ".colorscheme.json".text = builtins.toJSON config.colorscheme;
  };

  home.packages = let
    specialisation = pkgs.writeShellScriptBin "specialisation" ''
      profiles="$HOME/.local/state/nix/profiles"
      current="$profiles/home-manager"
      base="$profiles/home-manager-base"

      # If current contains specialisations, link it as base
      if [ -d "$current/specialisation" ]; then
        echo >&2 "Using current profile as base"
        ln -sfT "$(readlink "$current")" "$base"
      # Check that $base contains specialisations before proceeding
      elif [ -d "$base/specialisation" ]; then
        echo >&2 "Using previously linked base profile"
      else
        echo >&2 "No suitable base config found. Try 'home-manager switch' again."
        exit 1
      fi

      if [ -z "$1" ] || [ "$1" = "list" ] || [ "$1" = "-l" ] || [ "$1" = "--list" ]; then
        find "$base/specialisation" -type l -printf "%f\n"
        exit 0
      fi

      echo >&2 "Switching to ''${1} specialisation"
      if [ "$1" == "base"  ]; then
        "$base/activate"
      else
        "$base/specialisation/$1/activate"
      fi
    '';
    toggle-theme = pkgs.writeShellScriptBin "toggle-theme" ''
      if [ -n "$1" ]; then
        theme="$1"
      else
        current="$(${lib.getExe pkgs.jq} -re '.mode' "$HOME/.colorscheme.json")"
        if [ "$current" = "light" ]; then
          theme="dark"
        else
          theme="light"
        fi
      fi
      ${lib.getExe specialisation} "$theme"
    '';
  in [
    specialisation
    toggle-theme
  ];
}
