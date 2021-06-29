#!/usr/bin/env bash
insidecolor=$(flavours info -r $(flavours current) | sed -n '4 p')
ringcolor=$(flavours info -r $(flavours current) | sed -n '5 p')
errorcolor=$(flavours info -r $(flavours current) | sed -n '11 p')
clearedcolor=$(flavours info -r $(flavours current) | sed -n '15 p')
highlightcolor=$(flavours info -r $(flavours current) | sed -n '14 p')
verifyngcolor=$(flavours info -r $(flavours current) | sed -n '12 p')
textcolor=$(flavours info -r $(flavours current) | sed -n '10 p')
positiony="1000"
arguments="--effect-blur 20x3 --fade-in 0.1 --line-uses-inside --font Fira_Sans --font-size 15 --indicator-idle-visible --indicator-radius 40 --ring-color $ringcolor --inside-wrong-color $errorcolor --ring-wrong-color $errorcolor --indicator-y-position $positiony --key-hl-color $highlightcolor --bs-hl-color $errorcolor --ring-ver-color $verifyngcolor --inside-ver-color $verifyngcolor --inside-color $insidecolor --text-color $textcolor --text-clear-color $insidecolor --text-ver-color $insidecolor --text-wrong-color $insidecolor --text-caps-lock-color $textcolor --inside-clear-color $clearedcolor --ring-clear-color $clearedcolor --disable-caps-lock-text --indicator-caps-lock --inside-caps-lock-color $verifyngcolor --ring-caps-lock-color $ringcolor --separator-color $ringcolor"

swaylock $arguments $@
