#!/bin/bash

wm1="gnome"
wm2="qtile"
wm3="gnome-way"
wm4="qtile-way"
wm5="hyprland"
wm6="hyprland-nvidia"

single_wm_check() {
  found=0 
  argcount=0
  for args in "$@"; do
    ((argcount++))
    echo "$arg"
    echo "$argcount"
    case "$arg" in 
            "$wm1" | "$wm2" | "$wm3" | "$wm4" | "$wm5" | "$wm6")
                ((found++))
                ;;
        esac
    done

    echo "$found"

    if [ "$found" -gt 1 ]; then
        echo "too many window/desktop arguments passed. please only provide one."
        exit 1
    fi
}

echo "arguments: $(IFS=-; echo "$*")"
single_wm_check "$@"