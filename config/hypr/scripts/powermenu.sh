#!/usr/bin/env bash

suspend=$'\u23F8\uFE0E Suspend'
hibernate=$'\u23FE\uFE0E Hibernate'
logout=$'\u21A6 Exit Hyprland'
reboot=$'\u21BB Reboot'
shutdown=$'\u23FB Shutdown'

options="$suspend\n$hibernate\n$logout\n$reboot\n$shutdown"
selected=$(echo -e "$options" | wofi --show dmenu --width 200 --height 320 --prompt "Power Menu" --hide-search)

case $selected in
    "$shutdown")
        systemctl poweroff ;;
    "$reboot")
        systemctl reboot ;;
    "$suspend")
        systemctl suspend ;;
    "$hibernate")
        systemctl hibernate ;;
    "$logout")
        hyprctl dispatch exit ;;
esac
