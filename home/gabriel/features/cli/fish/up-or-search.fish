# Merge history upon doing up-or-search
# This lets multiple fish instances share history
if commandline --search-mode
    commandline -f history-search-backward
    return
end
if commandline --paging-mode
    commandline -f up-line
    return
end

set -l lineno (commandline -L)

switch $lineno
    case 1
        commandline -f history-search-backward
        # Here we go
        history merge
    case '*'
        commandline -f up-line
end
