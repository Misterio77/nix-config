{ pkgs, ... }:
let
  nix-inspect = pkgs.writeShellScriptBin "nix-inspect" ''
    read -ra EXCLUDED <<< "$@"

    IFS=":" read -ra PATHS <<< "$PATH"

    read -ra PROGRAMS <<< \
      "$(printf "%s\n" "''${PATHS[@]}" | ${pkgs.gnugrep}/bin/grep "\/nix\/store" | ${pkgs.perl}/bin/perl -pe 's/^\/nix\/store\/\w{32}-((?:[^-\/]|-(?!(?:\d|unstable)))+)(?:-?([^\/]*))\/.*$/\1/' | ${pkgs.findutils}/bin/xargs)"

    for to_remove in "''${EXCLUDED[@]}"; do
        PROGRAMS=("''${PROGRAMS[@]/$to_remove}")
    done

    read -ra PROGRAMS <<< "''${PROGRAMS[@]}"
    echo "''${PROGRAMS[@]}"
  '';
in
{
  programs.starship = {
    enable = true;
    settings = {
      format =
        let
          git = "$git_branch$git_commit$git_state$git_status";
          cloud = "$aws$gcloud$openstack";
        in
        ''
          $username$hostname( $shlvl)( $cmd_duration)
          ($nix_shell )''${custom.nix_inspect}
          $directory( ${git})(- ${cloud})
          $jobs$character
        '';

      # Core
      username = {
        format = "[$user]($style)";
        show_always = true;
      };
      hostname = {
        format = "[@$hostname]($style)";
        ssh_only = false;
        style = "bold green";
      };
      shlvl = {
        format = "[$shlvl]($style)";
        style = "bold cyan";
        threshold = 2;
        repeat = true;
      };
      cmd_duration = {
        format = "took [$duration]($style)";
      };

      directory = {
        format = "[$path]($style)( [$read_only]($read_only_style))";
      };
      nix_shell = {
        format = "via [$symbol$state( $name)]($style)";
        impure_msg = "";
        pure_msg = "λ";
      };
      custom = {
        nix_inspect = {
          disabled = false;
          when = true;
          command = "${nix-inspect}/bin/nix-inspect kitty imagemagick ncurses";
          format = "[$symbol(\\($output\\))]($style)";
          symbol = " ";
          style = "bold cyan";
        };
      };

      character = {
        error_symbol = "[~~>](bold red)";
        success_symbol = "[->>](bold green)";
        vicmd_symbol = "[<<-](bold yellow)";
      };

      # Cloud
      gcloud = {
        format = "on [$symbol$active(/$project)(\\($region\\))]($style)";
      };
      aws = {
        format = "on [$symbol$profile(\\($region\\))]($style)";
      };


      # Toggles \/
      shlvl.disabled = false;


      # Icon changes only \/
      aws.symbol = "  ";
      conda.symbol = " ";
      dart.symbol = " ";
      directory.read_only = " ";
      docker_context.symbol = " ";
      elixir.symbol = " ";
      elm.symbol = " ";
      gcloud.symbol = " ";
      git_branch.symbol = " ";
      golang.symbol = " ";
      hg_branch.symbol = " ";
      java.symbol = " ";
      julia.symbol = " ";
      memory_usage.symbol = " ";
      nim.symbol = " ";
      nix_shell.symbol = "";
      nodejs.symbol = " ";
      package.symbol = " ";
      perl.symbol = " ";
      php.symbol = " ";
      python.symbol = " ";
      ruby.symbol = " ";
      rust.symbol = " ";
      scala.symbol = " ";
      shlvl.symbol = "";
      swift.symbol = "ﯣ ";
      terraform.symbol = "行";
    };
  };
}
