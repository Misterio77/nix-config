#!/usr/bin/env bash
source ~/.colors
insidecolor=$base01
ringcolor=$base02
errorcolor=$base08
clearedcolor=$base0C
highlightcolor=$base0B
verifyngcolor=$base09
textcolor=$base07

positiony="1000"
arguments="--effect-blur 20x3 --fade-in 0.1 --line-uses-inside --font Fira_Sans --font-size 15 --indicator-idle-visible --indicator-radius 40 --ring-color $ringcolor --inside-wrong-color $errorcolor --ring-wrong-color $errorcolor --indicator-y-position $positiony --key-hl-color $highlightcolor --bs-hl-color $errorcolor --ring-ver-color $verifyngcolor --inside-ver-color $verifyngcolor --inside-color $insidecolor --text-color $textcolor --text-clear-color $insidecolor --text-ver-color $insidecolor --text-wrong-color $insidecolor --text-caps-lock-color $textcolor --inside-clear-color $clearedcolor --ring-clear-color $clearedcolor --disable-caps-lock-text --indicator-caps-lock --inside-caps-lock-color $verifyngcolor --ring-caps-lock-color $ringcolor --separator-color $ringcolor"

swaylock $arguments $@
