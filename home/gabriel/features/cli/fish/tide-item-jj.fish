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
)' | string trim)
set jj_info $jj_status
_tide_print_item jj $tide_jj_icon' ' (
    set_color black; echo -ns '('
    set_color white; echo -ns "$(string join ', ' $jj_info)"
    set_color black; echo -ns ')'
)
