{
  programs.starship = {
    enable = true;
    settings = {
      format = ''
        $username$hostname$shlvl $cmd_duration
        $directory$git_branch$git_commit$git_state$git_status$hg_branch$docker_context$package$cmake$dart$dotnet$elixir$elm$erlang$golang$helm$java$julia$kotlin$nim$nodejs$ocaml$perl$php$purescript$python$ruby$rust$swift$terraform$zig$nix_shell$conda$memory_usage$aws$gcloud$openstack$env_var$crystal
        $jobs$character
      '';
      username = {
        show_always = true;
        format = "[$user]($style)";
      };
      hostname = {
        ssh_only = false;
        format = "[@$hostname]($style)";
        style = "bold green";
      };
      directory = { };
      character = {
        success_symbol = "[->>](bold green)";
        error_symbol = "[~~>](bold red)";
        vicmd_symbol = "[<<-](bold yellow)";
      };
      aws = {
        symbol = "  ";
        format = "on [$symbol$profile(\\($region\\))]($style) ";
      };
      gcloud = {
        symbol = " ";
        format = "on [$symbol$active(/$project)(\\($region\\))]($style) ";
      };
      nix_shell = {
        impure_msg = "";
        pure_msg = "λ ";
        symbol = "";
        format = "via [$symbol$state( $name)]($style) ";
      };
      conda.symbol = " ";
      dart.symbol = " ";
      directory.read_only = " ";
      docker_context.symbol = " ";
      elixir.symbol = " ";
      elm.symbol = " ";
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
      shlvl.symbol = " ";
      swift.symbol = "ﯣ ";
      terraform.symbol = "行";
    };
  };
}
