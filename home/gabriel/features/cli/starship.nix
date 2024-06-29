{
  pkgs,
  lib,
  ...
}: {
  programs.starship = {
    enable = true;
    settings = {
      format = let
        git = "$git_branch$git_commit$git_state$git_status";
        cloud = "$aws$gcloud$openstack";
      in ''
        $username$hostname($shlvl)($cmd_duration) $fill ($nix_shell)''${custom.nix_inspect}
        $directory(${git})(${cloud})(''${custom.juju}) $fill $time
        $jobs$character
      '';

      fill = {
        symbol = " ";
        disabled = false;
      };

      # Core
      username = {
        format = "[$user]($style)";
        show_always = true;
      };
      hostname = {
        format = "[@$hostname]($style) ";
        ssh_only = false;
        style = "bold green";
      };
      shlvl = {
        format = "[$shlvl]($style) ";
        style = "bold cyan";
        threshold = 2;
        repeat = true;
        disabled = false;
      };
      cmd_duration = {
        format = "took [$duration]($style) ";
      };

      directory = {
        format = "[$path]($style)( [$read_only]($read_only_style)) ";
      };
      nix_shell = {
        format = "[($name \\(develop\\) <- )$symbol]($style) ";
        impure_msg = "";
        symbol = " ";
        style = "bold red";
      };
      custom = {
        nix_inspect = let
          excluded = [
            "kitty"
            "imagemagick"
            "ncurses"
            "user-environment"
          ];
        in {
          disabled = false;
          when = "test -z $IN_NIX_SHELL";
          command = "${lib.getExe pkgs.nix-inspect} ${lib.concatStringsSep " " excluded}";
          format = "[($output <- )$symbol]($style) ";
          symbol = " ";
          style = "bold blue";
        };
        juju = let
          commandScript = pkgs.writeShellApplication {
            name = "juju-prompt";
            runtimeInputs = [pkgs.yq];
            checkPhase = false;
            text = ''
              JUJU_DATA="''${JUJU_DATA:-$HOME/.local/share/juju}"
              if [ -z "''${JUJU_CONTROLLER:-}" ]; then
                JUJU_CONTROLLER="$(yq -re '."current-controller"' "$JUJU_DATA/controllers.yaml" || exit 1)"
              fi
              if [ -z "''${JUJU_MODEL:-}" ]; then
                JUJU_MODEL="$(yq -r --arg model "$JUJU_CONTROLLER" '.controllers."$model"."current-model"' "$JUJU_DATA/models.yaml" || true)"
              fi

              if [ -z "$JUJU_MODEL"] || [ "$JUJU_MODEL" = "null" ]; then
                echo "$JUJU_CONTROLLER"
              else
                echo "$JUJU_MODEL ($JUJU_CONTROLLER)"
              fi
            '';
          };
          whenScript = pkgs.writeShellScriptBin "juju-prompt-when" ''
            builtin type -P juju &>/dev/null && test -e "''${JUJU_DATA:-$HOME/.local/share/juju}/controllers.yaml"
          '';
        in {
          disabled = false;
          when = lib.getExe whenScript;
          command = lib.getExe commandScript;
          format = "on [$symbol($output)]($style)";
          symbol = " ";
          style = "bold fg:208";
        };
      };

      character = {
        error_symbol = "[~~>](bold red)";
        success_symbol = "[->>](bold green)";
        vimcmd_symbol = "[<<-](bold yellow)";
        vimcmd_visual_symbol = "[<<-](bold cyan)";
        vimcmd_replace_symbol = "[<<-](bold purple)";
        vimcmd_replace_one_symbol = "[<<-](bold purple)";
      };

      time = {
        format = "\\\[[$time]($style)\\\]";
        disabled = false;
      };

      # Cloud
      gcloud = {
        format = "on [$symbol$active(/$project)(\\($region\\))]($style)";
      };
      aws = {
        format = "on [$symbol$profile(\\($region\\))]($style)";
      };

      # Icon changes only \/
      aws.symbol = " ";
      conda.symbol = " ";
      dart.symbol = " ";
      directory.read_only = " ";
      docker_context.symbol = " ";
      elm.symbol = " ";
      elixir.symbol = "";
      gcloud.symbol = " ";
      git_branch.symbol = " ";
      golang.symbol = " ";
      hg_branch.symbol = " ";
      java.symbol = " ";
      julia.symbol = " ";
      memory_usage.symbol = "󰍛 ";
      nim.symbol = "󰆥 ";
      nodejs.symbol = " ";
      package.symbol = "󰏗 ";
      perl.symbol = " ";
      php.symbol = " ";
      python.symbol = " ";
      ruby.symbol = " ";
      rust.symbol = " ";
      scala.symbol = " ";
      shlvl.symbol = "";
      swift.symbol = "󰛥 ";
      terraform.symbol = "󱁢";
    };
  };
}
