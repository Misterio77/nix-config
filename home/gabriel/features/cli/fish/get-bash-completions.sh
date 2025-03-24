#!/usr/bin/env bash
# Author: Brian Beffa <brbsix@gmail.com>
# Original source: https://brbsix.github.io/2015/11/29/accessing-tab-completion-programmatically-in-bash/
# License: LGPLv3 (http://www.gnu.org/licenses/lgpl-3.0.txt)
#

get_completions(){
    local completion COMP_CWORD COMP_LINE COMP_POINT COMP_WORDS COMPREPLY=()

    COMP_LINE=$*
    COMP_POINT=${#COMP_LINE}

    eval set -- "$@"

    COMP_WORDS=("$@")

    # add '' to COMP_WORDS if the last character of the command line is a space
    [[ ${COMP_LINE[@]: -1} = ' ' ]] && COMP_WORDS+=('')

    # index of the last word
    COMP_CWORD=$(( ${#COMP_WORDS[@]} - 1 ))

    # load completion
    _comp_load -D -- "$1"

    # detect completion
    completion=$(complete -p "$1" 2>/dev/null | awk '{print $(NF-1)}')

    # ensure completion was detected
    [[ -n $completion ]] || return 1

    # execute completion function
    "$completion"

    # print completions to stdout
    for ((i = 0; i < ${#COMPREPLY[@]}; i++)); do
        echo "${COMPREPLY[$i]%%*( )}"
    done
}
