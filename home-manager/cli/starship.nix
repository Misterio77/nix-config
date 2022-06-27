{ pkgs, ... }:
let
  nix-inspect = pkgs.writeShellScriptBin "nix-inspect" ''
    read -ra EXCLUDED <<< "$@"

    IFS=":" read -ra PATHS <<< "$PATH"

    read -ra PROGRAMS <<< \
      "$(printf "%s\n" "''${PATHS[@]}" | ${pkgs.gnugrep}/bin/grep "\/nix\/store" | ${pkgs.perl}/bin/perl -pe 's/^\/nix\/store\/\w{32}-(.*)\/.*$/\1/' | ${pkgs.findutils}/bin/xargs)"

    for to_remove in "''${EXCLUDED[@]}"; do
        to_remove_full="$(printf "%s\n" "''${PROGRAMS[@]}" | grep "$to_remove" )"
        PROGRAMS=("''${PROGRAMS[@]/$to_remove_full}")
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
          $directory( ${git})(- ${cloud})
          ($nix_shell )''${custom.nix_inspect}
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
        format = "[$symbol(-> $name \\(develop\\))]($style)";
        impure_msg = "";
        symbol = " ";
        style = "bold red";
      };
      custom = {
        nix_inspect = {
          disabled = false;
          when = "test -z $IN_NIX_SHELL";
          command = "${nix-inspect}/bin/nix-inspect kitty imagemagick ncurses";
          format = "[$symbol(-> $output)]($style)";
          symbol = " ";
          style = "bold blue";
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
