{pkgs, ...}: {
  programs.fish = {
    plugins = [
      {
        name = "tide";
        src = pkgs.fetchFromGitHub {
          owner = "IlanCosman";
          repo = "tide";
          rev = "44c521ab292f0eb659a9e2e1b6f83f5f0595fcbd";
          hash = "sha256-85iU1QzcZmZYGhK30/ZaKwJNLTsx+j3w6St8bFiQWxc=";
        };
      }
    ];
    interactiveShellInit = /* fish */ ''
      tide configure --auto --style=Lean --prompt_colors='16 colors' --show_time='24-hour format' --lean_prompt_height='Two lines' --prompt_connection=Disconnected --prompt_spacing=Sparse --icons='Few icons' --transient=No
      set tide_left_prompt_items pwd git jj newline character
      set tide_character_icon ">"
      set tide_character_vi_icon_default "<"
    '';
    functions = {
      # Prompt item for jujutsu VCS
      _tide_item_jj = /* fish */ ''
        if not command -sq jj; or not jj root --quiet &>/dev/null
            return 1
        end

        set jj_status (jj log -r@ -n1 --ignore-working-copy --no-graph --color always -T '
          separate(" ",
            branches.map(|x| if(
              x.name().substr(0, 10).starts_with(x.name()),
              x.name().substr(0, 10),
              x.name().substr(0, 9) ++ "…")
            ).join(" "),
            tags.map(|x| if(
              x.name().substr(0, 10).starts_with(x.name()),
              x.name().substr(0, 10),
              x.name().substr(0, 9) ++ "…")
            ).join(" "),
            surround("\"","\"",
              if(
                description.first_line().substr(0, 24).starts_with(description.first_line()),
                description.first_line().substr(0, 24),
                description.first_line().substr(0, 23) ++ "…"
              )
            ),
            change_id.shortest(),
            commit_id.shortest(),
            if(empty, "(empty)"),
            if(conflict, "(conflict)"),
            if(divergent, "(divergent)"),
            if(hidden, "(hidden)"),
          )
        ' | string trim)
        _tide_print_item jj $tide_jj_icon' ' (
            set_color black; echo -ns '('
            set_color white; echo -ns "$(string join ', ' $jj_status)"
            set_color black; echo -ns ')'
        )
      '';
    };
  };
}
