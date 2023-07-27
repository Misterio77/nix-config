{ writeShellApplication, hyprland, jq, slurp }:
writeShellApplication {
  name = "hyprslurp";
  runtimeInputs = [ hyprland jq slurp ];
  text = ''
    hyprctl clients -j | \
    jq -r \
      --argjson workspaces "$(\
        hyprctl monitors -j | \
        jq -r 'map(.activeWorkspace.id)'\
      )" \
      'map(select([.workspace.id] | inside($workspaces)))' | \
    jq -r '.[] | "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"' | \
    slurp "$@"
  '';
}
